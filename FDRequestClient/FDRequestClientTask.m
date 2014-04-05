#import "FDRequestClientTask.h"
#import "FDURLResponse+Private.h"
#import <FDFoundationKit/NSObject+PerformBlock.h>
@import UIKit.UIImage;


#pragma mark Constants

#define UnknownDataLength ((long long)-1)


#pragma mark - Class Extension

@interface FDRequestClientTask ()

typedef NSURLSessionAuthChallengeDisposition (^FDRequestClientTaskAuthorizationBlock)(NSURLAuthenticationChallenge *urlAuthenticationChallenge, NSURLCredential **urlCredential);
typedef void (^FDRequestClientTaskProgressBlock)(float progress);
typedef id (^FDRequestClientTaskDataParserBlock)(NSData *data);
typedef id (^FDRequestClientTaskTransformBlock)(id object);
typedef void (^FDRequestClientTaskCompletionBlock)(FDURLResponse *urlResponse);

@end


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation FDRequestClientTask
{
	@private __strong FDRequestClientTaskAuthorizationBlock _authorizationBlock;
	@private __strong FDRequestClientTaskProgressBlock _progressBlock;
	@private __strong FDRequestClientTaskDataParserBlock _dataParserBlock;
	@private __strong FDRequestClientTaskTransformBlock _transformBlock;
	@private __strong NSMutableArray *_completionBlocks;
	@private long long _expectedDataLength;
	@private __strong NSMutableData *_receivedData;
	@private __strong NSLock *_completionLock;
}


#pragma mark - Properties


#pragma mark - Constructors

- (id)_initWithURLSessionTask: (NSURLSessionTask *)urlSessionTask 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	transformBlock: (FDRequestClientTaskTransformBlock)transformBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_urlSessionTask = urlSessionTask;
	_callCompletionBlockOnMainThread = YES;
	_authorizationBlock = authorizationBlock;
	_progressBlock = progressBlock;
	_dataParserBlock = dataParserBlock;
	_transformBlock = transformBlock;
	_completionBlocks = [NSMutableArray array];
	_expectedDataLength = UnknownDataLength;
	_receivedData = nil;
	_completionLock = [NSLock new];
	
	[self addCompletionBlock: completionBlock];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods

- (BOOL)addCompletionBlock: (FDRequestClientTaskCompletionBlock)completionBlock
{
	// If the completion lock is already activated that means the completion blocks are being iterated over and there is no way to add this completion block. The user should be notified that their attempt to add a completion block has failed.
	if ([_completionLock tryLock] == NO)
	{
		return NO;
	}
	
	[_completionBlocks addObject: completionBlock];
	
	// Once the completion block has been successfully added the completion lock can be unlocked.
	[_completionLock unlock];
	
	return YES;
}

- (void)suspend
{
	[_urlSessionTask suspend];
}

- (void)resume
{
	[_urlSessionTask resume];
}

- (void)cancel
{
	[_urlSessionTask cancel];
}


#pragma mark - Overridden Methods


#pragma mark - Private Methods

- (NSURLSessionAuthChallengeDisposition)_dispositionForChallenge: (NSURLAuthenticationChallenge *)challenge 
	credential: (NSURLCredential **)credential
{
	NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
	
	// If an authorization block exists call it to get the disposition and credential.
	if (_authorizationBlock != nil)
	{
		disposition = _authorizationBlock(challenge, credential);
	}
	
	return disposition;
}

- (void)_didReceiveResponse: (NSURLResponse *)response
{
	// Store the expected data length, if it is known.
	long long expectedContentLength = [response expectedContentLength];
	
	NSInteger capacity = 0;
	
	if (expectedContentLength != NSURLResponseUnknownLength)
	{
		_expectedDataLength = expectedContentLength;
		
		capacity = (NSUInteger)_expectedDataLength;
	}
	
	// Create container to store received data.
	_receivedData = [[NSMutableData alloc] 
		initWithCapacity: capacity];
}

- (void)_didReceiveData: (NSData *)data
{
	// Append received 
	[_receivedData appendData: data];
	
	// If the expected data length is known, calculate the current progress of the download.
	if (_expectedDataLength != UnknownDataLength 
		&& _progressBlock != nil)
	{
		float progress = [_receivedData length] / (float)_expectedDataLength;
		
		_progressBlock(progress);
	}
}

- (void)_didCompleteWithError: (NSError *)error
{
	id responseContent = nil;
	
	// Pass the received data into the data parser block, if it exists.
	if (_dataParserBlock != nil)
	{
		responseContent = _dataParserBlock(_receivedData);
	}
	// Otherwise, parse the received data into the specified format.
	else
	{
		NSString *mimeType = _urlSessionTask.response.MIMEType;
		if (mimeType == nil)
		{
		}
		else if ([mimeType rangeOfString: @"text/"].location != NSNotFound)
		{
			NSString *receivedDataAsString = [[NSString alloc] 
				initWithData: _receivedData 
					encoding: NSUTF8StringEncoding];
			
			responseContent = receivedDataAsString;
		}
		else if ([mimeType rangeOfString: @"image/"].location != NSNotFound)
		{
			responseContent = [UIImage imageWithData: _receivedData];
		}
		else if ([mimeType isEqualToString: @"application/json"] == YES)
		{
			// Ensure the received data is not nil before attempting to parse it.
			if (_receivedData != nil)
			{
				responseContent = [NSJSONSerialization JSONObjectWithData: _receivedData 
					options: NSJSONReadingAllowFragments 
					error: nil];
			}
		}
		else
		{
			[NSException raise: NSInternalInconsistencyException 
				format: @"Unsupported MIME type: %@\n%s", 
					mimeType, 
					__PRETTY_FUNCTION__];
		}
	}
	
	// If it exists, call the transform block on the parsed content.
	if (_transformBlock != nil)
	{
		responseContent = _transformBlock(responseContent);
	}
	
	// If an error was returned or the status code is not 2XX or 3XX assume the task failed.
	// TODO: Check if the task was cancelled.
	FDURLResponseStatus status = FDURLResponseStatusSucceed;
	if (error != nil)
	{
		status = FDURLResponseStatusFailed;
	}
	else if ([_urlSessionTask.response isKindOfClass: [NSHTTPURLResponse class]] == YES)
	{
		NSInteger statusCode = [(NSHTTPURLResponse *)_urlSessionTask.response statusCode];
		if (statusCode < 200 
			|| statusCode >= 400)
		{
			status = FDURLResponseStatusFailed;
		}
	}
	
	FDURLResponse *urlResponse = [[FDURLResponse alloc] 
		initWithStatus: status 
			content: responseContent 
			error: error 
			rawURLResponse: _urlSessionTask.response];
	
	// Because the completion blocks are about to iterated over this code needs to be locked so no new completion blocks can be added.
	[_completionLock lock];
	
	if (_callCompletionBlockOnMainThread == YES)
	{
		[self performBlockOnMainThread: ^
		{
			for (FDRequestClientTaskCompletionBlock completionBlock in _completionBlocks)
			{
				completionBlock(urlResponse);
			}
		}];
	}
	else
	{
		for (FDRequestClientTaskCompletionBlock completionBlock in _completionBlocks)
		{
			completionBlock(urlResponse);
		}
	}
	
	// Release all completion blocks to prevent possible circular retains on the operation.
	_completionBlocks = nil;
	
	// Once all the completion blocks have been iterated over and released the completion lock can be unlocked.
	[_completionLock unlock];
}


@end