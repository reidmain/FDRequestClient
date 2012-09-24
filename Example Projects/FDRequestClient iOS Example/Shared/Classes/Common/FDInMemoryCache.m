#import "FDInMemoryCache.h"
#import "FDHTTPRequest.h"
#import "FDURLResponse+Private.h"


#pragma mark Class Definition

@implementation FDInMemoryCache
{
	@private NSCache *_cache;
}


#pragma mark -
#pragma mark Constructors

- (id)init
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_cache = [[NSCache alloc] 
		init];
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc
{
	// Release instance variables.
	[_cache release];
	
	// Call the base destructor.
	[super dealloc];
}


#pragma mark -
#pragma mark FDRequestClientCache Methods

- (void)requestClient: (FDRequestClient *)requestClient 
	cacheURLResponse: (FDURLResponse *)urlResponse
{
	[_cache setObject: urlResponse.content 
		forKey: [[urlResponse rawURLResponse] URL]];
}

- (FDURLResponse *)requestClient: (FDRequestClient *)requestClient 
	cachedURLResponseForURLRequest: (FDURLRequest *)urlRequest
{
	FDURLResponse *cachedResponse = nil;
	
	// Only get cached results for HTTP GET requests.
	if ([urlRequest isKindOfClass: [FDHTTPRequest class]])
	{
		FDHTTPRequest *httpRequest = (FDHTTPRequest *)urlRequest;
		
		if ([httpRequest.method caseInsensitiveCompare: FDHTTPRequestMethodGet] == NSOrderedSame)
		{
			id cachedResponseContent = [_cache objectForKey: [httpRequest url]];
			
			if (cachedResponseContent != nil)
			{
				cachedResponse = [[[FDURLResponse alloc] 
					_initWithStatus: FDURLResponseStatusSucceed 
						content: cachedResponseContent 
						error: nil 
						rawURLResponse: nil] 
							autorelease];
			}
		}
	}
	
	return cachedResponse;
}

- (FDURLResponse *)requestClient: (FDRequestClient *)requestClient 
	cachedURLResponseForURLRequest: (NSURLRequest *)urlRequest 
	withRequestType: (FDURLRequestType)requestType
{
	FDURLResponse *cachedResponse = nil;
	
	// Only get cached results for HTTP GET requests.
	if ([[urlRequest HTTPMethod] caseInsensitiveCompare: FDHTTPRequestMethodGet] == NSOrderedSame)
	{
		id cachedResponseContent = [_cache objectForKey: [urlRequest URL]];
		
		if (cachedResponseContent != nil)
		{
			cachedResponse = [[[FDURLResponse alloc] 
				_initWithStatus: FDURLResponseStatusSucceed 
					content: cachedResponseContent 
					error: nil 
					rawURLResponse: nil] 
						autorelease];
		}
	}
	
	return cachedResponse;
}


@end // @implementation FDInMemoryCache