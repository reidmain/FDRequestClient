#import "FDTwitterList.h"


#pragma mark Class Definition

@implementation FDTwitterList


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
	_listId = nil;
	_name = nil;
	_listDescription = nil;
	_memberCount = 0;
	_subscriberCount = 0;
	_creator = nil;
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Overridden Methods

- (NSString *)description
{
	NSString *description = [NSString stringWithFormat: @"<FDTwitterList = {Id %@, Name: %@, Creator: %@}>", 
		_listId, 
		_name, 
		_creator];
	
	return description;
}


@end // @implementation FDTwitterList