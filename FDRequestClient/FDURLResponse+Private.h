#import "FDURLResponse.h"


#pragma mark Class Interface

@interface FDURLResponse ()


#pragma mark - Constructors

- (id)initWithStatus: (FDURLResponseStatus)status 
	content: (id)content 
	error: (NSError *)error 
	rawURLResponse: (NSURLResponse *)rawURLResponse;


@end