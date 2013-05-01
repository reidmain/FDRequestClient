#import "FDRequestClient.h"
#import "FDURLConnection.h"
#import "FDURLConnectionOperation.h"


#pragma mark Class Extension

@interface FDRequestClient ()

- (FDURLConnectionDataParserBlock)_dataParserBlockForDataType: (NSString *)dataType;


@end


#pragma mark - Class Definition

@implementation FDRequestClient
{
	@private __strong NSOperationQueue *_operationQueue;
}


#pragma mark - Constructors

- (id)initWithOperationQueue: (NSOperationQueue *)operationQueue
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_operationQueue = operationQueue;
	_delegate = nil;
	_cache = nil;
	
	// Return initialized instance.
	return self;
}

- (id)initWithSharedOperationQueue: (BOOL)useSharedOperationQueue
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
		
		operationQueue.maxConcurrentOperationCount = 1;
	}
	
	// Abort if base initializer fails.
	if ((self = [self initWithOperationQueue: operationQueue]) == nil)
	{
		return nil;
	}
	
	// Return initialized instance.
	return self;
}


- (id)init
{
	// Abort if base initializer fails.
	if ((self = [self initWithSharedOperationQueue: NO]) == nil)
	{
		return nil;
	}
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods

- (FDURLConnectionOperation *)loadURLRequest: (NSURLRequest *)urlRequest 
	urlRequestType: (FDURLRequestType)urlRequestType 
	authorizationBlock: (FDURLConnectionAuthorizationBlock)authorizationBlock 
	progressBlock: (FDURLConnectionProgressBlock)progressBlock 
	dataParserBlock: (FDURLConnectionDataParserBlock)dataParserBlock 
	transformBlock: (FDURLConnectionTransformBlock)transformBlock 
	completionBlock: (FDURLConnectionOperationCompletionBlock)completionBlock
{
	FDURLConnectionOperation *urlConnectionOperation = nil;
	
	FDURLResponse *cachedResponse = [_cache requestClient: self 
		cachedURLResponseForURLRequest: urlRequest 
		withRequestType: urlRequestType];
	
	if (cachedResponse != nil)
	{
		completionBlock(cachedResponse);
	}
	else
	{
		if (dataParserBlock == nil)
		{
			dataParserBlock = [self _dataParserBlockForDataType: urlRequestType];
		}
		
		urlConnectionOperation = [[FDURLConnectionOperation alloc] 
			initWithURLRequest: urlRequest 
				urlRequestType: urlRequestType 
				authorizationBlock: authorizationBlock 
				progressBlock: progressBlock 
				dataParserBlock: dataParserBlock 
				transformBlock: transformBlock 
				completionBlock: completionBlock];
		
		[urlConnectionOperation addCompletionBlock: ^(FDURLResponse *urlResponse)
			{
				if (urlResponse.status == FDURLResponseStatusSucceed)
				{
					[_cache requestClient: self 
						cacheURLResponse: urlResponse];
				}
			}];
		
		[_operationQueue addOperation: urlConnectionOperation];
	}
	
	return urlConnectionOperation;
}

- (FDURLConnectionOperation *)loadURLRequest: (FDURLRequest *)urlRequest 
	authorizationBlock: (FDURLConnectionAuthorizationBlock)authorizationBlock 
	progressBlock: (FDURLConnectionProgressBlock)progressBlock 
	dataParserBlock: (FDURLConnectionDataParserBlock)dataParserBlock 
	transformBlock: (FDURLConnectionTransformBlock)transformBlock 
	completionBlock: (FDURLConnectionOperationCompletionBlock)completionBlock
{
	FDURLConnectionOperation *urlConnectionOperation = nil;
	
	FDURLResponse *cachedResponse = [_cache requestClient: self 
		cachedURLResponseForURLRequest: urlRequest];
	
	if (cachedResponse != nil)
	{
		completionBlock(cachedResponse);
	}
	else
	{
		if (dataParserBlock == nil)
		{
			dataParserBlock = [self _dataParserBlockForDataType: urlRequest.type];
		}
		
		urlConnectionOperation = [[FDURLConnectionOperation alloc] 
			initWithURLRequest: urlRequest 
				authorizationBlock: authorizationBlock 
				progressBlock: progressBlock 
				dataParserBlock: dataParserBlock 
				transformBlock: transformBlock 
				completionBlock: completionBlock];
		
		[urlConnectionOperation addCompletionBlock: ^(FDURLResponse *urlResponse)
			{
				if (urlResponse.status == FDURLResponseStatusSucceed)
				{
					[_cache requestClient: self 
						cacheURLResponse: urlResponse];
				}
			}];
		
		[_operationQueue addOperation: urlConnectionOperation];
	}
	
	return urlConnectionOperation;
}


#pragma mark - Private Methods

- (FDURLConnectionDataParserBlock)_dataParserBlockForDataType: (NSString *)dataType
{
	FDURLConnectionDataParserBlock dataParserBlock = nil;
	
	if ([_delegate respondsToSelector: @selector(requestClient:canParseDataType:)])
	{
		BOOL canParseDataType = [_delegate requestClient: self 
			canParseDataType: dataType];
		
		if (canParseDataType == YES 
			&& [_delegate respondsToSelector: @selector(requestClient:parseData:withDataType:)])
		{
			dataParserBlock = ^id(NSData *data)
			{
				id parsedData = [_delegate requestClient: self 
					parseData: data 
					withDataType: dataType];
				
				return parsedData;
			};
		}
	}
	
	return dataParserBlock;
}


@end