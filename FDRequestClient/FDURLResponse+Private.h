#import "FDURLResponse.h"


#pragma mark Class Interface

@interface FDURLResponse ()


#pragma mark -
#pragma mark Constructors

- (id)_initWithStatus: (FDURLResponseStatus)status 
	content: (id)content 
	error: (NSError *)error 
	rawURLResponse: (NSURLResponse *)rawURLResponse;


@end // @interface FDURLResponse ()