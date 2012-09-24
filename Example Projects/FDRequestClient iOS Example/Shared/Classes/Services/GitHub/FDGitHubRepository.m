#import "FDGitHubRepository.h"


#pragma mark Class Definition

@implementation FDGitHubRepository
{
	@private NSString *_name;
	@private NSString *_owner;
	@private NSString *_repoDescription;
	@private NSString *_language;
	@private unsigned int _forkCount;
	@private unsigned int _watcherCount;
	@private unsigned int _followerCount;
	@private NSURL *_url;
	@private NSDate *_creationDate;
	@private NSDate *_lastPushDate;
}


#pragma mark -
#pragma mark Properties

@synthesize name = _name;
@synthesize owner = _owner;
@synthesize repoDescription = _repoDescription;
@synthesize language = _language;
@synthesize forkCount = _forkCount;
@synthesize watcherCount = _watcherCount;
@synthesize followerCount = _followerCount;
@synthesize url = _url;
@synthesize creationDate = _creationDate;
@synthesize lastPushDate = _lastPushDate;


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
	_name = nil;
	_owner = nil;
	_repoDescription = nil;
	_language = nil;
	_forkCount = 0;
	_watcherCount = 0;
	_followerCount = 0;
	_url = nil;
	_creationDate = nil;
	_lastPushDate = nil;
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc
{
	// Release instance variables.
	[_name release];
	[_owner release];
	[_repoDescription release];
	[_language release];
	[_url release];
	[_creationDate release];
	[_lastPushDate release];
	
	// Call the base destructor.
	[super dealloc];
}


#pragma mark -
#pragma mark Overridden Methods

- (NSString *)description
{
	NSString *description = [NSString stringWithFormat: @"<FDGitHubRepository = {Name: %@, Description: %@, URL: %@}>", 
		_name, 
		_repoDescription, 
		_url];
	
	return description;
}


@end // @implementation FDGitHubRepository