#import "FDTwitterList.h"


#pragma mark Class Definition

@implementation FDTwitterList
{
	@private NSString *_listId;
	@private NSString *_name;
	@private NSString *_listDescription;
	@private unsigned int _memberCount;
	@private unsigned int _subscriberCount;
	@private FDTwitterUser *_creator;
}


#pragma mark -
#pragma mark Properties

@synthesize listId = _listId;
@synthesize name = _name;
@synthesize listDescription = _listDescription;
@synthesize memberCount = _memberCount;
@synthesize subscriberCount = _subscriberCount;
@synthesize creator = _creator;


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
#pragma mark Destructor

- (void)dealloc
{
	// Release instance variables.
	[_listId release];
	[_name release];
	[_listDescription release];
	[_creator release];
	
	// Call the base destructor.
	[super dealloc];
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