#import "FDURLResponse.h"
#import "FDURLResponse+Private.h"


#pragma mark Class Definition

@implementation FDURLResponse


#pragma mark - Constructors

- (id)initWithStatus: (FDURLResponseStatus)status 
	content: (id)content 
	error: (NSError *)error 
	rawURLResponse: (NSURLResponse *)rawURLResponse
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}

	
	// Initialize instance variables.
	_status = status;
	_content = content;
	_error = error;
	_rawURLResponse = rawURLResponse;
	
	// Return initialized instance.
	return self;
}


@end