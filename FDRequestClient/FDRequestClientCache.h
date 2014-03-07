#import "FDURLResponse.h"


#pragma mark Forward Declarations

@class FDRequestClient;


#pragma mark - Protocol

@protocol FDRequestClientCache<
	NSObject>


#pragma mark - Required Methods

@required

- (void)requestClient: (FDRequestClient *)requestClient 
	cacheURLResponse: (FDURLResponse *)urlResponse;

- (FDURLResponse *)requestClient: (FDRequestClient *)requestClient 
	cachedURLResponseForHTTPRequest: (FDHTTPRequest *)httpRequest;

- (FDURLResponse *)requestClient: (FDRequestClient *)requestClient 
	cachedURLResponseForURLRequest: (NSURLRequest *)urlRequest;


@end