#import "FDRequestClient.h"
#import "FDRequestClientTask+Private.h"


#pragma mark Class Extension

@interface FDRequestClient ()

//- (FDURLConnectionDataParserBlock)_dataParserBlockForDataType: (NSString *)dataType;


@end


#pragma mark - Class Definition

@implementation FDRequestClient
{
	@private __strong NSURLSession *_urlSession;
	@private __strong NSMutableDictionary *_activeTasks;
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
	_activeTasks = [NSMutableDictionary dictionary];
	
	_delegate = nil;
	_cache = nil;
	
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
		initWithURLSessionTask: dataTask 
			urlRequestType: urlRequestType 
			authorizationBlock: authorizationBlock 
			progressBlock: progressBlock 
			dataParserBlock: dataParserBlock 
			transformBlock: transformBlock 
			completionBlock: completionBlock];
	
	[_activeTasks setObject: requestClientTask 
		forKey: @(dataTask.taskIdentifier)];
	
	[dataTask resume];
	
	return requestClientTask;
//	FDURLConnectionOperation *urlConnectionOperation = nil;
//	
//	FDURLResponse *cachedResponse = [_cache requestClient: self 
//		cachedURLResponseForURLRequest: urlRequest 
//		withRequestType: urlRequestType];
//	
//	if (cachedResponse != nil)
//	{
//		completionBlock(cachedResponse);
//	}
//	else
//	{
//		if (dataParserBlock == nil)
//		{
//			dataParserBlock = [self _dataParserBlockForDataType: urlRequestType];
//		}
//		
//		urlConnectionOperation = [[FDURLConnectionOperation alloc] 
//			initWithURLRequest: urlRequest 
//				urlRequestType: urlRequestType 
//				authorizationBlock: authorizationBlock 
//				progressBlock: progressBlock 
//				dataParserBlock: dataParserBlock 
//				transformBlock: transformBlock 
//				completionBlock: completionBlock];
//		
//		[urlConnectionOperation addCompletionBlock: ^(FDURLResponse *urlResponse)
//			{
//				if (urlResponse.status == FDURLResponseStatusSucceed)
//				{
//					[_cache requestClient: self 
//						cacheURLResponse: urlResponse];
//				}
//			}];
//		
//		[_operationQueue addOperation: urlConnectionOperation];
//	}
//	
//	return urlConnectionOperation;
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
	
//	FDURLConnectionOperation *urlConnectionOperation = nil;
//	
//	FDURLResponse *cachedResponse = [_cache requestClient: self 
//		cachedURLResponseForURLRequest: urlRequest];
//	
//	if (cachedResponse != nil)
//	{
//		completionBlock(cachedResponse);
//	}
//	else
//	{
//		if (dataParserBlock == nil)
//		{
//			dataParserBlock = [self _dataParserBlockForDataType: urlRequest.type];
//		}
//		
//		urlConnectionOperation = [[FDURLConnectionOperation alloc] 
//			initWithURLRequest: urlRequest 
//				authorizationBlock: authorizationBlock 
//				progressBlock: progressBlock 
//				dataParserBlock: dataParserBlock 
//				transformBlock: transformBlock 
//				completionBlock: completionBlock];
//		
//		[urlConnectionOperation addCompletionBlock: ^(FDURLResponse *urlResponse)
//			{
//				if (urlResponse.status == FDURLResponseStatusSucceed)
//				{
//					[_cache requestClient: self 
//						cacheURLResponse: urlResponse];
//				}
//			}];
//		
//		[_operationQueue addOperation: urlConnectionOperation];
//	}
//	
//	return urlConnectionOperation;
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