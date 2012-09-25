#import "FDTwitterUser.h"


#pragma mark Constants

static NSString * const CodingKey_UserId = @"userId";
static NSString * const CodingKey_ScreenName = @"screenName";
static NSString * const CodingKey_Name = @"name";
static NSString * const CodingKey_Location = @"location";
static NSString * const CodingKey_URL = @"url";
static NSString * const CodingKey_Bio = @"bio";
static NSString * const CodingKey_ProfileImageURL = @"profileImageURL";
static NSString * const CodingKey_FollowingCount = @"followingCount";
static NSString * const CodingKey_FollowerCount = @"followerCount";
static NSString * const CodingKey_ListedCount = @"listedCount";
static NSString * const CodingKey_FollowedByAuthenticatedUser = @"followedByAuthenticatedUser";


#pragma mark -
#pragma mark Class Definition

@implementation FDTwitterUser
{
	@private __strong NSString *_userId;
	@private __strong NSString *_screenName;
	@private __strong NSString *_name;
	@private __strong NSString *_location;
	@private __strong NSURL *_url;
	@private __strong NSString *_bio;
	@private __strong NSURL *_profileImageURL;
	@private unsigned int _followingCount;
	@private unsigned int _followerCount;
	@private unsigned int _listedCount;
	@private BOOL _followedByAuthenticatedUser;
}


#pragma mark -
#pragma mark Properties

@synthesize userId = _userId;
@synthesize screenName = _screenName;
@synthesize name = _name;
@synthesize location = _location;
@synthesize url = _url;
@synthesize bio = _bio;
@synthesize profileImageURL = _profileImageURL;
@synthesize followingCount = _followingCount;
@synthesize followerCount = _followerCount;
@synthesize listedCount = _listedCount;
@synthesize followedByAuthenticatedUser = _followedByAuthenticatedUser;


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
	_userId = nil;
	_screenName = nil;
	_name = nil;
	_location = nil;
	_url = nil;
	_bio = nil;
	_profileImageURL = nil;
	_followingCount = 0;
	_followingCount = 0;
	_listedCount = 0;
	_followedByAuthenticatedUser = NO;
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Overridden Methods

- (NSString *)description
{
	NSString *description = [NSString stringWithFormat: @"<FDTwitterUser = {Name: %@}>", 
		_name];
	
	return description;
}


#pragma mark -
#pragma mark NSCoding Methods

- (id)initWithCoder: (NSCoder *)coder
{
	// Abort if base initializer fails.
	if ((self = [self init]) == nil)
	{
		return nil;
	}
	
	NSString *userId = [coder decodeObjectForKey: CodingKey_UserId];
	NSString *screenName = [coder decodeObjectForKey: CodingKey_ScreenName];
	NSString *name = [coder decodeObjectForKey: CodingKey_Name];
	NSString *location = [coder decodeObjectForKey: CodingKey_Location];
	NSURL *url = [coder decodeObjectForKey: CodingKey_URL];
	NSString *bio = [coder decodeObjectForKey: CodingKey_Bio];
	NSURL *profileImageURL = [coder decodeObjectForKey: CodingKey_ProfileImageURL];
	NSNumber *followingCount = [coder decodeObjectForKey: CodingKey_FollowingCount];
	NSNumber *followerCount = [coder decodeObjectForKey: CodingKey_FollowerCount];
	NSNumber *listedCount = [coder decodeObjectForKey: CodingKey_ListedCount];
	BOOL followedByAuthenticatedUser = [coder decodeBoolForKey: CodingKey_FollowedByAuthenticatedUser];
	
	_userId = [userId copy];
	_screenName = [screenName copy];
	_name = [name copy];
	_location = [location copy];
	_url = [url copy];
	_bio = [bio copy];
	_profileImageURL = [profileImageURL copy];
	_followingCount = [followingCount unsignedIntValue];
	_followerCount = [followerCount unsignedIntValue];
	_listedCount = [listedCount unsignedIntValue];
	_followedByAuthenticatedUser = followedByAuthenticatedUser;
	
	// Return initialized instance.
	return self;
}

- (void)encodeWithCoder: (NSCoder *)coder
{
	[coder encodeObject: _userId 
		forKey: CodingKey_UserId];
	
	[coder encodeObject: _screenName 
		forKey: CodingKey_ScreenName];
	
	[coder encodeObject: _name 
		forKey: CodingKey_Name];
	
	[coder encodeObject: _location 
		forKey: CodingKey_Location];
	
	[coder encodeObject: _url 
		forKey: CodingKey_URL];
	
	[coder encodeObject: _bio 
		forKey: CodingKey_Bio];
	
	[coder encodeObject: _profileImageURL 
		forKey: CodingKey_ProfileImageURL];
	
	[coder encodeObject: [NSNumber numberWithUnsignedInt: _followingCount] 
		forKey: CodingKey_FollowingCount];
	
	[coder encodeObject: [NSNumber numberWithUnsignedInt: _followerCount] 
		forKey: CodingKey_FollowerCount];
	
	[coder encodeObject: [NSNumber numberWithUnsignedInt: _listedCount] 
		forKey: CodingKey_ListedCount];
	
	[coder encodeBool: _followedByAuthenticatedUser 
		forKey: CodingKey_FollowedByAuthenticatedUser];
}


@end // @implementation FDTwitterUser