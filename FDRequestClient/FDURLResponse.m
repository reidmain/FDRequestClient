#import "FDURLResponse.h"
#import "FDURLResponse+Private.h"


#pragma mark Class Definition

@implementation FDURLResponse
{
	@private FDURLResponseStatus _status;
	@private id _content;
	@private NSError *_error;
	@private NSURLResponse *_rawURLResponse;
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
	_content = [content retain];
	_error = [error retain];
	_rawURLResponse = [rawURLResponse retain];
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc
{
	// Release instance variables.
	[_content release];
	[_error release];
	[_rawURLResponse release];
	
	// Call the base destructor.
	[super dealloc];
}


@end // @implementation FDURLResponse