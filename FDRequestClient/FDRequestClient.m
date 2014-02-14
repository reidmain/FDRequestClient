#import "FDRequestClient.h"
#import "FDRequestClientTask+Private.h"
#import "FDThreadSafeMutableDictionary.h"


#pragma mark Class Extension

@interface FDRequestClient ()

//- (FDURLConnectionDataParserBlock)_dataParserBlockForDataType: (NSString *)dataType;


@end


#pragma mark - Class Definition

@implementation FDRequestClient
{
	@private __strong NSURLSession *_urlSession;
	@private __strong FDThreadSafeMutableDictionary *_activeTasks;
}


#pragma mark - Constructors

- (id)initWithOperationQueue: (NSOperationQueue *)operationQueue 
	urlSessionConfiguration: (NSURLSessionConfiguration *)urlSessionConfiguration
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_urlSession = [NSURLSession sessionWithConfiguration: urlSessionConfiguration 
		delegate: self 
		delegateQueue: operationQueue];
	_activeTasks = [FDThreadSafeMutableDictionary dictionary];
	
	_delegate = nil;
	_cache = nil;
	_headerFieldsToLog = @[ @"Authorization" ];
	
	// Return initialized instance.
	return self;
}

- (id)initWithSharedOperationQueue: (BOOL)useSharedOperationQueue 
	urlSessionConfiguration: (NSURLSessionConfiguration *)urlSessionConfiguration
{
	NSOperationQueue *operationQueue = nil;
	
	if (useSharedOperationQueue == YES)
	{
		static NSOperationQueue *sharedOperationQueue = nil;
		
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, 
			^{
				sharedOperationQueue = [[NSOperationQueue alloc] 
					init];
			});
		
		operationQueue = sharedOperationQueue;
	}
	else
	{
		operationQueue = [[NSOperationQueue alloc] 
			init];
		
		operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
	}
	
	// Abort if base initializer fails.
	if ((self = [self initWithOperationQueue: operationQueue 
		urlSessionConfiguration: urlSessionConfiguration]) == nil)
	{
		return nil;
	}
	
	// Return initialized instance.
	return self;
}


- (id)init
{
	// Abort if base initializer fails.
	if ((self = [self initWithSharedOperationQueue: NO 
		urlSessionConfiguration: nil]) == nil)
	{
		return nil;
	}
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods

- (FDRequestClientTask *)loadURLRequest: (NSURLRequest *)urlRequest 
	urlRequestType: (FDURLRequestType)urlRequestType 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	transformBlock: (FDRequestClientTaskTransformBlock)transformBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;
{
	NSURLSessionDataTask *dataTask = [_urlSession dataTaskWithRequest: urlRequest];
	
	FDRequestClientTask *requestClientTask = [[FDRequestClientTask alloc] 
		_initWithURLSessionTask: dataTask 
			urlRequestType: urlRequestType 
			authorizationBlock: authorizationBlock 
			progressBlock: progressBlock 
			dataParserBlock: dataParserBlock 
			transformBlock: transformBlock 
			completionBlock: completionBlock];
	
	[_activeTasks setObject: requestClientTask 
		forKey: @(dataTask.taskIdentifier)];
	
	[dataTask resume];
	
	// Log a curl command so it is easy to see what requests are being made.
	NSMutableString *headerOptions = [NSMutableString string];
	
	// Add header options that have been requested to be logged to the curl command.
	NSDictionary *headerFields = [urlRequest allHTTPHeaderFields];
	[_headerFieldsToLog enumerateObjectsUsingBlock: ^(NSString *headerField, NSUInteger index, BOOL *stop)
		{
			NSString *value = [headerFields objectForKey: headerField];
			if (FDIsEmpty(value) == NO)
			{
				[headerOptions appendFormat: @" -H \"%@: %@\"", headerField, value];
			}
		}];
	
	FDLog(FDLogLevelInfo, @"curl%@ \"%@\"", headerOptions, [urlRequest URL]);
	
	return requestClientTask;
}

- (FDRequestClientTask *)loadURLRequest: (FDURLRequest *)urlRequest 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	transformBlock: (FDRequestClientTaskTransformBlock)transformBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock
{
	FDRequestClientTask *requestClientTask = [self loadURLRequest: urlRequest.rawURLRequest 
		urlRequestType: urlRequest.type 
		authorizationBlock: authorizationBlock 
		progressBlock: progressBlock 
		dataParserBlock: dataParserBlock 
		transformBlock: transformBlock 
		completionBlock: completionBlock];
	
	return requestClientTask;
}


#pragma mark - Private Methods

//- (FDURLConnectionDataParserBlock)_dataParserBlockForDataType: (NSString *)dataType
//{
//	FDURLConnectionDataParserBlock dataParserBlock = nil;
//	
//	if ([_delegate respondsToSelector: @selector(requestClient:canParseDataType:)])
//	{
//		BOOL canParseDataType = [_delegate requestClient: self 
//			canParseDataType: dataType];
//		
//		if (canParseDataType == YES 
//			&& [_delegate respondsToSelector: @selector(requestClient:parseData:withDataType:)])
//		{
//			dataParserBlock = ^id(NSData *data)
//			{
//				id parsedData = [_delegate requestClient: self 
//					parseData: data 
//					withDataType: dataType];
//				
//				return parsedData;
//			};
//		}
//	}
//	
//	return dataParserBlock;
//}


#pragma mark - NSURLSessionDelegate Methods

- (void)URLSession: (NSURLSession *)session 
	didBecomeInvalidWithError: (NSError *)error
{
	// TODO: Implemenent this.
	NSLog(@"Implement %s", __PRETTY_FUNCTION__);
}

//- (void)URLSession: (NSURLSession *)session 
//	didReceiveChallenge: (NSURLAuthenticationChallenge *)challenge 
//	completionHandler: (void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
//{
//	// TODO: Implement this.
//	NSLog(@"Implement %s", __PRETTY_FUNCTION__);
//}


#pragma mark - NSURLSessionTaskDelegate Methods

- (void)URLSession: (NSURLSession *)session 
	task: (NSURLSessionTask *)task 
	didReceiveChallenge: (NSURLAuthenticationChallenge *)challenge 
	completionHandler: (void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
	NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
	NSURLCredential *credential = nil;
	
	FDRequestClientTask *requestClientTask = [_activeTasks objectForKey: @(task.taskIdentifier)];
	disposition = [requestClientTask _dispositionForChallenge: challenge 
		credential: &credential];
	
	completionHandler(disposition, credential);
}

- (void)URLSession: (NSURLSession *)session 
	task: (NSURLSessionTask *)task 
	didSendBodyData: (int64_t)bytesSent 
	totalBytesSent: (int64_t)totalBytesSent 
	totalBytesExpectedToSend: (int64_t)totalBytesExpectedToSend
{
	NSLog(@"WTF? %s", __PRETTY_FUNCTION__);
}

- (void)URLSession: (NSURLSession *)session 
	task: (NSURLSessionTask *)task 
	didCompleteWithError: (NSError *)error
{
	FDRequestClientTask *requestClientTask = [_activeTasks objectForKey: @(task.taskIdentifier)];
	[requestClientTask _didCompleteWithError: error];
	
	[_activeTasks removeObjectForKey: @(requestClientTask.urlSessionTask.taskIdentifier)];
}


#pragma mark - NSURLSessionDataDelegate Methods

- (void)URLSession: (NSURLSession *)session 
	dataTask: (NSURLSessionDataTask *)dataTask 
	didReceiveResponse: (NSURLResponse *)response 
	completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
	FDRequestClientTask *requestClientTask = [_activeTasks objectForKey: @(dataTask.taskIdentifier)];
	[requestClientTask _didReceiveResponse: response];
	
	completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession: (NSURLSession *)session 
	dataTask: (NSURLSessionDataTask *)dataTask
	didReceiveData: (NSData *)data
{
	FDRequestClientTask *requestClientTask = [_activeTasks objectForKey: @(dataTask.taskIdentifier)];
	[requestClientTask _didReceiveData: data];
}

//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
//                                  willCacheResponse:(NSCachedURLResponse *)proposedResponse 
//                                  completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler;


@end