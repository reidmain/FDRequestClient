#import "FDTweet.h"


#pragma mark Class Definition

@implementation FDTweet
{
	@private __strong NSString *_tweetId;
	@private __strong FDTwitterUser *_user;
	@private __strong NSString *_text;
	@private __strong NSDate *_creationDate;
	@private __strong NSMutableArray *_urls;
	@private BOOL _favourited;
	@private BOOL _retweeted;
	@private unsigned int _retweetCount;
}


#pragma mark -
#pragma mark Properties

@synthesize tweetId = _tweetId;
@synthesize user = _user;
@synthesize text = _text;
@synthesize creationDate = _creationDate;
@synthesize urls = _urls;
@synthesize favourited = _favourited;
@synthesize retweeted = _retweeted;
@synthesize retweetCount = _retweetCount;


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
	_tweetId = nil;
	_user = nil;
	_text = nil;
	_creationDate = nil;
	_urls = [[NSMutableArray alloc] 
		init];
	_favourited = NO;
	_retweeted = NO;
	_retweetCount = 0;
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Overridden Methods

- (NSString *)description
{
	NSString *description = [NSString stringWithFormat: @"<FDTweet = {Id: %@, Text: %@, URLs: %@}>", 
		_tweetId, 
		_text, 
		_urls];
	
	return description;
}


@end // @implementation FDTweet