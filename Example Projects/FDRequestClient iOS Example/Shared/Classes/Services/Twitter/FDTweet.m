#import "FDTweet.h"


#pragma mark Class Definition

@implementation FDTweet


#pragma mark - Constructors

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


@end