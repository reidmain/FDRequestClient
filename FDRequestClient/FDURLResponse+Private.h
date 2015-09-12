#import "FDURLResponse.h"


#pragma mark - Class Interface

@interface FDURLResponse ()


#pragma mark - Initializers

- (instancetype)initWithStatus: (FDURLResponseStatus)status 
	content: (id)content 
	error: (NSError *)error 
	rawURLResponse: (NSURLResponse *)rawURLResponse;


@end