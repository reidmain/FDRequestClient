#import "FDRequestClientTask.h"
#import "FDRequestClientTask+Private.h"
#import "FDURLResponse+Private.h"
#import <FDFoundationKit/NSObject+PerformBlock.h>
#import <FDFoundationKit/FDNullOrEmpty.h>
@import UIKit.UIImage;


#pragma mark Constants

#define UnknownDataLength ((long long)-1)

NSString * const FDRequestClientTaskErrorDomain = @"com.1414degrees.requestclienttask";


#pragma mark - Class Extension

@interface FDRequestClientTask ()


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
	@private float _uploadProgress;
	@private float _downloadProgress;
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
	_uploadProgress = 0.0f;
	_downloadProgress = 0.0f;
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
	// If the completion block is nil there is nothing to add.
	if (FDIsEmpty(completionBlock) == YES)
	{
		return NO;
	}
	
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

- (void)_didSendBodyData: (int64_t)bytesSent 
	totalBytesSent: (int64_t)totalBytesSent 
	totalBytesExpectedToSend: (int64_t)totalBytesExpectedToSend
{
	// Calculate the progress of the upload.
	if (_progressBlock != nil)
	{
		_uploadProgress = totalBytesSent / (float)totalBytesExpectedToSend;
		
		_progressBlock(_uploadProgress, _downloadProgress);
	}
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
	// Append received data.
	[_receivedData appendData: data];
	
	// If the expected data length is known, calculate the current progress of the download.
	if (_expectedDataLength != UnknownDataLength 
		&& _progressBlock != nil)
	{
		_downloadProgress = [_receivedData length] / (float)_expectedDataLength;
		
		_progressBlock(_uploadProgress, _downloadProgress);
	}
}

- (void)_didCompleteWithError: (NSError *)error
{
	FDURLResponseStatus status = FDURLResponseStatusSucceed;
	id responseContent = nil;
	
	// Check if the task was cancelled by looking for a specific error.
	if ([[error domain] isEqualToString: NSURLErrorDomain] == YES 
		&& [error code] == NSURLErrorCancelled)
	{
		status = FDURLResponseStatusCancelled;
	}
	// If the task was not cancelled attempt to parse the response and handle any errors.
	else
	{
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
		
		// If an error was returned the task has failed.
		if (error != nil)
		{
			status = FDURLResponseStatusFailed;
		}
		// If the the status code is not 2XX or 3XX assume the task failed and create a error object from the status code.
		else if ([_urlSessionTask.response isKindOfClass: [NSHTTPURLResponse class]] == YES)
		{
			NSInteger statusCode = [(NSHTTPURLResponse *)_urlSessionTask.response statusCode];
			if (statusCode < 200 
				|| statusCode >= 400)
			{
				status = FDURLResponseStatusFailed;
				
				NSString *statusCodeString = [NSHTTPURLResponse localizedStringForStatusCode: statusCode];
				
				NSDictionary *userInfo = @{ 
					NSLocalizedFailureReasonErrorKey : statusCodeString 
					};
				
				error = [NSError errorWithDomain: FDRequestClientTaskErrorDomain 
					code: statusCode 
					userInfo: userInfo];
			}
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
		// Create a reference to the completion blocks to ensure they will always exist whenever the call on the main thread occurs.
		NSArray *completionBlocks = _completionBlocks;
		
		[self performBlockOnMainThread: ^
			{
				for (FDRequestClientTaskCompletionBlock completionBlock in completionBlocks)
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