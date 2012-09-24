#import "FDTwitterURL.h"


#pragma mark Class Definition

@implementation FDTwitterURL
{
	@private NSURL *_rawURL;
	@private NSURL *_displayURL;
	@private NSURL *_expandedURL;
}


#pragma mark -
#pragma mark Properties

@synthesize rawURL = _rawURL;
@synthesize displayURL = _displayURL;
@synthesize expandedURL = _expandedURL;


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
	_rawURL = nil;
	_displayURL = nil;
	_expandedURL = nil;
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc
{
	// Release instance variables.
	[_rawURL release];
	[_displayURL release];
	[_expandedURL release];
	
	// Call the base destructor.
	[super dealloc];
}


#pragma mark -
#pragma mark Overridden Methods

- (NSString *)description
{
	NSString *description = [NSString stringWithFormat: @"<FDTwitterURL = {Raw: %@, Display: %@, Expanded: %@}>", 
		_rawURL, 
		_displayURL, 
		_expandedURL];
	
	return description;
}


@end // @implementation FDTwitterURL