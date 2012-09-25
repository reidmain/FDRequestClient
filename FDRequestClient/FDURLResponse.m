#import "FDURLResponse.h"
#import "FDURLResponse+Private.h"


#pragma mark Class Definition

@implementation FDURLResponse
{
	@private FDURLResponseStatus _status;
	@private __strong id _content;
	@private __strong NSError *_error;
	@private __strong NSURLResponse *_rawURLResponse;
}


#pragma mark -
#pragma mark Properties

@synthesize status = _status;
@synthesize content = _content;
@synthesize error = _error;
@synthesize rawURLResponse = _rawURLResponse;


#pragma mark -
#pragma mark Constructors

- (id)_initWithStatus: (FDURLResponseStatus)status 
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


@end // @implementation FDURLResponse