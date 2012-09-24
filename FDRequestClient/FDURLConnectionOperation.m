#import "FDURLConnectionOperation.h"
#import "FDURLRequest.h"
#import "NSObject+PerformBlock.h"


#pragma mark Class Extension

@interface FDURLConnectionOperation ()

- (id)_initWithAuthorizationBlock: (FDURLConnectionAuthorizationBlock)authorizationBlock 
	progressBlock: (FDURLConnectionProgressBlock)progessBlock 
	dataParserBlock: (FDURLConnectionDataParserBlock)dataParserBlock 
	transformBlock: (FDURLConnectionTransformBlock)transformBlock 
	completionBlock: (FDURLConnectionOperationCompletionBlock)completionBlock;


@end // @interface FDURLConnectionOperation ()


#pragma mark -
#pragma mark Class Definition

@implementation FDURLConnectionOperation
{
	@private NSMutableArray *_completionBlocks;
	@private FDURLConnection *_urlConnection;
	@private FDURLConnectionAuthorizationBlock _authorizationBlock;
	@private FDURLConnectionProgressBlock _progressBlock;
	@private FDURLConnectionDataParserBlock _dataParserBlock;
	@private FDURLConnectionTransformBlock _transformBlock;
}


#pragma mark -
#pragma mark Properties


#pragma mark -
#pragma mark Constructors

- (id)_initWithAuthorizationBlock: (FDURLConnectionAuthorizationBlock)authorizationBlock 
	progressBlock: (FDURLConnectionProgressBlock)progessBlock 
	dataParserBlock: (FDURLConnectionDataParserBlock)dataParserBlock 
	transformBlock: (FDURLConnectionTransformBlock)transformBlock 
	completionBlock: (FDURLConnectionOperationCompletionBlock)completionBlock;
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_completionBlocks = [[NSMutableArray alloc] 
		init];
	_authorizationBlock = [authorizationBlock copy];
	_progressBlock = [progessBlock copy];
	_dataParserBlock = [dataParserBlock copy];
	_transformBlock = [transformBlock copy];
	
	[self addCompletionBlock: completionBlock];
	
	// Return initialized variables.
	return self;
}

- (id)initWithURLRequest: (NSURLRequest *)urlRequest 
	urlRequestType: (FDURLRequestType)urlRequestType 
	authorizationBlock: (FDURLConnectionAuthorizationBlock)authorizationBlock 
	progressBlock: (FDURLConnectionProgressBlock)progessBlock 
	dataParserBlock: (FDURLConnectionDataParserBlock)dataParserBlock 
	transformBlock: (FDURLConnectionTransformBlock)transformBlock 
	completionBlock: (FDURLConnectionOperationCompletionBlock)completionBlock
{
	// Abort if base initializer fails.
	if ((self = [self _initWithAuthorizationBlock: authorizationBlock 
		progressBlock: progessBlock 
		dataParserBlock: dataParserBlock 
		transformBlock: transformBlock 
		completionBlock: completionBlock]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_urlConnection = [[FDURLConnection alloc] 
		initWithURLRequest: urlRequest 
			urlRequestType: urlRequestType];
	
	// Return initialized instance.
	return self;
}

- (id)initWithURLRequest: (FDURLRequest *)urlRequest 
	authorizationBlock: (FDURLConnectionAuthorizationBlock)authorizationBlock 
	progressBlock: (FDURLConnectionProgressBlock)progessBlock 
	dataParserBlock: (FDURLConnectionDataParserBlock)dataParserBlock 
	transformBlock: (FDURLConnectionTransformBlock)transformBlock 
	completionBlock: (FDURLConnectionOperationCompletionBlock)completionBlock
{
	// Abort if base initializer fails.
	if ((self = [self _initWithAuthorizationBlock: authorizationBlock 
		progressBlock: progessBlock 
		dataParserBlock: dataParserBlock 
		transformBlock: transformBlock 
		completionBlock: completionBlock]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_urlConnection = [[FDURLConnection alloc] 
		initWithURLRequest: urlRequest];
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc
{
	// Release instance variables.
	[_completionBlocks release];
	[_urlConnection release];
	[_authorizationBlock release];
	[_progressBlock release];
	[_dataParserBlock release];
	[_transformBlock release];
	
	// Call the base destructor.
    [super dealloc];
}


#pragma mark -
#pragma mark Public Methods

- (void)addCompletionBlock: (FDURLConnectionOperationCompletionBlock)completionBlock
{
	// NOTE: We need to copy the completion block before we add to the the array so it can be moved from the heap to the stack.
	FDURLConnectionOperationCompletionBlock copiedCompletionBlock = [completionBlock copy];
	
	[_completionBlocks addObject: copiedCompletionBlock];
	
	[copiedCompletionBlock release];
}


#pragma mark -
#pragma mark Overridden Methods

- (void)main
{
	// Load the response for the URL connection.
	FDURLResponse *urlResponse = [_urlConnection loadWithAuthorizationBlock: _authorizationBlock 
		progressBlock: _progressBlock 
		dataParserBlock: _dataParserBlock 
		transformBlock: _transformBlock];
	
	// Pass the response to the completion block on the main thread.
	[self performBlockOnMainThread: ^
		{
			//TODO: Copy the array before we enumerate through it because this object is not thread safe.
			for (FDURLConnectionOperationCompletionBlock completionBlock in _completionBlocks)
			{
				completionBlock(urlResponse);
			}
		}];
	
	// Release all completion blocks to prevent possible circular retains on the operation.
	[_completionBlocks removeAllObjects];
}

- (void)cancel
{
	[super cancel];
	
	[_urlConnection cancel];
}


@end // @implementation FDURLConnectionOperation