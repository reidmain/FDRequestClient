#import "FDRequestClient.h"
#import "FDRequestClientTask+Private.h"


#pragma mark Class Extension

@interface FDRequestClient ()


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
	
	_logCurlCommandsToConsole = YES;
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
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	transformBlock: (FDRequestClientTaskTransformBlock)transformBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;
{
	NSURLSessionDataTask *dataTask = [_urlSession dataTaskWithRequest: urlRequest];
	
	FDRequestClientTask *requestClientTask = [[FDRequestClientTask alloc] 
		_initWithURLSessionTask: dataTask 
			authorizationBlock: authorizationBlock 
			progressBlock: progressBlock 
			dataParserBlock: dataParserBlock 
			transformBlock: transformBlock 
			completionBlock: completionBlock];
	
	[_activeTasks setObject: requestClientTask 
		forKey: @(dataTask.taskIdentifier)];
	
	[dataTask resume];
	
	[UIApplication showNetworkActivityIndicator];
	
	if (_logCurlCommandsToConsole == YES)
	{
		// Log a curl command so it is easy to see what requests are being made.
		NSMutableString *headerOptions = [NSMutableString string];
		
		// Add requested header fields to the curl command being logged.
		NSDictionary *headerFields = [urlRequest allHTTPHeaderFields];
		[_headerFieldsToLog enumerateObjectsUsingBlock: ^(NSString *headerField, NSUInteger index, BOOL *stop)
			{
				NSString *value = [headerFields objectForKey: headerField];
				if (FDIsEmpty(value) == NO)
				{
					[headerOptions appendFormat: @"-H \"%@: %@\" ", headerField, value];
				}
			}];
		
		FDLog(FDLogLevelInfo, @"curl -X %@ %@\"%@\"", [urlRequest HTTPMethod], headerOptions, [[[urlRequest URL] absoluteString] urlDecode]);
	}
	
	return requestClientTask;
}

- (FDRequestClientTask *)loadHTTPRequest: (FDHTTPRequest *)httpRequest 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	transformBlock: (FDRequestClientTaskTransformBlock)transformBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock
{
	FDRequestClientTask *requestClientTask = [self loadURLRequest: [httpRequest urlRequest] 
		authorizationBlock: authorizationBlock 
		progressBlock: progressBlock 
		dataParserBlock: dataParserBlock 
		transformBlock: transformBlock 
		completionBlock: completionBlock];
	
	return requestClientTask;
}


#pragma mark - Private Methods


#pragma mark - NSURLSessionDelegate Methods

- (void)URLSession: (NSURLSession *)session 
	didBecomeInvalidWithError: (NSError *)error
{
	FDLogger(FDLogLevelTrace, 
		@"The URL session has somehow become invalid. The FDRequestClient should be updated to account for this scenario.\n%@", 
		session);
}


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
	FDRequestClientTask *requestClientTask = [_activeTasks objectForKey: @(task.taskIdentifier)];
	[requestClientTask _didSendBodyData: bytesSent 
		totalBytesSent: totalBytesSent 
		totalBytesExpectedToSend: totalBytesExpectedToSend];
}

- (void)URLSession: (NSURLSession *)session 
	task: (NSURLSessionTask *)task 
	didCompleteWithError: (NSError *)error
{
	FDRequestClientTask *requestClientTask = [_activeTasks objectForKey: @(task.taskIdentifier)];
	[requestClientTask _didCompleteWithError: error];
	
	[_activeTasks removeObjectForKey: @(requestClientTask.urlSessionTask.taskIdentifier)];
	
	[UIApplication hideNetworkActivityIndicator];
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


@end