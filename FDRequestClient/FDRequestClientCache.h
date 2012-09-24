#import "FDURLRequest.h"
#import "FDURLResponse.h"


#pragma mark Forward Declarations

@class FDRequestClient;


#pragma mark -
#pragma mark Protocol

@protocol FDRequestClientCache<
	NSObject>


#pragma mark -
#pragma mark Required Methods

@required

- (void)requestClient: (FDRequestClient *)requestClient 
	cacheURLResponse: (FDURLResponse *)urlResponse;

- (FDURLResponse *)requestClient: (FDRequestClient *)requestClient 
	cachedURLResponseForURLRequest: (FDURLRequest *)urlRequest;

- (FDURLResponse *)requestClient: (FDRequestClient *)requestClient 
	cachedURLResponseForURLRequest: (NSURLRequest *)urlRequest 
	withRequestType: (FDURLRequestType)requestType;


@end // @protocol FDRequestClientCache