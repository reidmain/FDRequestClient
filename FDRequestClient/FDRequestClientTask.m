#import "FDRequestClientTask.h"
#import "FDURLResponse+Private.h"
#import "NSObject+PerformBlock.h"
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
	@private __strong FDURLRequestType _urlRequestType;
	@private __strong FDRequestClientTaskAuthorizationBlock _authorizationBlock;
	@private __strong FDRequestClientTaskProgressBlock _progressBlock;
	@private __strong FDRequestClientTaskDataParserBlock _dataParserBlock;
	@private __strong FDRequestClientTaskTransformBlock _transformBlock;
	@private __strong NSMutableArray *_completionBlocks;
	@private long long _expectedDataLength;
	@private __strong NSMutableData *_receivedData;
}


#pragma mark - Properties


#pragma mark - Constructors

- (id)_initWithURLSessionTask: (NSURLSessionTask *)urlSessionTask 
	urlRequestType: (FDURLRequestType)urlRequestType 
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
	_urlRequestType = [urlRequestType copy];
	_authorizationBlock = authorizationBlock;
	_progressBlock = progressBlock;
	_dataParserBlock = dataParserBlock;
	_transformBlock = transformBlock;
	_completionBlocks = [NSMutableArray array];
	_expectedDataLength = UnknownDataLength;
	_receivedData = nil;
	
	[self addCompletionBlock: completionBlock];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods

- (void)addCompletionBlock: (FDRequestClientTaskCompletionBlock)completionBlock
{
	[_completionBlocks addObject: completionBlock];
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
		if ([_urlRequestType isEqualToString: FDURLRequestTypeRaw] == YES)
		{
			responseContent = _receivedData;
		}
		else if ([_urlRequestType isEqualToString: FDURLRequestTypeString] == YES)
		{
			NSString *receivedDataAsString = [[NSString alloc] 
				initWithData: _receivedData 
					encoding: NSUTF8StringEncoding];
			
			responseContent = receivedDataAsString;
		}
		else if ([_urlRequestType isEqualToString: FDURLRequestTypeImage] == YES)
		{
			responseContent = [UIImage imageWithData: _receivedData];
		}
		else if ([_urlRequestType isEqualToString: FDURLRequestTypeJSON] == YES)
		{
			// TODO: can't call this if data is nil. Happened when connection failed.
			responseContent = [NSJSONSerialization JSONObjectWithData: _receivedData 
				options: NSJSONReadingAllowFragments 
				error: nil];
		}
		else
		{
			[NSException raise: NSInternalInconsistencyException 
				format: @"Unsupported request type: %@\n%s", 
					_urlRequestType, 
					__PRETTY_FUNCTION__];
		}
	}
	
	// If it exists, call the transform block on the parsed content.
	if (_transformBlock != nil)
	{
		responseContent = _transformBlock(responseContent);
	}
	
	FDURLResponseStatus status = FDURLResponseStatusSucceed;
	
	if (error != nil)
	{
		status = FDURLResponseStatusFailed;
	}
	
	FDURLResponse *urlResponse = [[FDURLResponse alloc] 
		initWithStatus: status 
			content: responseContent 
			error: error 
			rawURLResponse: _urlSessionTask.response];
	
	NSLog(@"%s\t%@", __PRETTY_FUNCTION__, [NSThread currentThread]);
	
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
}


@end