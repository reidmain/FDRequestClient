#import "FDTwitterAPIClient.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import "NSDictionary+Accessing.h"
#import <FDRequestClient/FDNullOrEmpty.h>


#pragma mark Class Extension

@interface FDTwitterAPIClient ()

- (NSURL *)_resourceURLForMethodName: (NSString *)methodName;

- (void)_setMaxTweetId: (NSString *)maxTweetId 
	forParameters: (NSMutableDictionary *)parameters;

- (void)_loadRequest: (SLRequest *)request 
	transformBlock: (FDURLConnectionTransformBlock)transformBlock 
	completionBlock: (FDURLConnectionOperationCompletionBlock)completionBlock;

- (FDTwitterUser *)_twitterUserFromJSONObject: (NSDictionary *)jsonObject;
- (FDTweet *)_tweetFromJSONObject: (NSDictionary *)jsonObject;
- (FDTwitterList *)_twitterListFromJSONObject: (NSDictionary *)jsonObject;

- (NSArray *)_twitterUsersFromJSONObject: (NSArray *)jsonObject;
- (NSArray *)_tweetsFromJSONObject: (NSArray *)jsonObject;
- (NSArray *)_twitterListsFromJSONObject: (NSArray *)jsonObject;


@end


#pragma mark - Class Variables

static NSDateFormatter *_apiDateFormatter;
static NSDateFormatter *_searchDateFormatter;


#pragma mark - Class Definition

@implementation FDTwitterAPIClient


#pragma mark - Constructors

+ (void)initialize
{
	// NOTE: initialize is called in a thead-safe manner so we don't need to worry about two shared instances possibly being created.
	
	// Create a flag to keep track of whether or not this class has been initialized because this method could be called a second time if a subclass does not override it.
	static BOOL classInitialized = NO;
	
	// If this class has not been initialized then create the shared instance.
	if (classInitialized == NO)
	{
		_apiDateFormatter = [[NSDateFormatter alloc] 
			init];
		[_apiDateFormatter setDateFormat: @"EEE MMM dd HH:mm:ss Z yyyy"];
//		[_apiDateFormatter setLocale: [[[NSLocale alloc] initWithLocaleIdentifier: @"en_US"] autorelease]];
		
		_searchDateFormatter = [[NSDateFormatter alloc] 
			init];
		[_searchDateFormatter setDateFormat: @"EEE, dd MMM yyyy HH:mm:ss Z"];
//		[_searchDateFormatter setLocale: [[[NSLocale alloc] initWithLocaleIdentifier: @"en_US"] autorelease]];
		
		classInitialized = YES;
	}
}

- (id)init
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods

- (void)listsForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	account: (ACAccount *)account 
	completion: (void (^)(FDURLResponseStatus status, NSError *error, NSArray *lists, NSString *nextCursor))completion
{
	// Create resource URL for lists request.
	NSURL *resourceURL = [self _resourceURLForMethodName: @"lists"];
	
	// Create parameters for lists request.
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] 
		initWithObjectsAndKeys: userId, 
			@"user_id", 
			nil];
	
	// Create lists request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: resourceURL 
		parameters: parameters];
	
	request.account = account;
	
	// Load list request.
	[self _loadRequest: request 
		transformBlock: ^id(id jsonObject)
		{
			// Transform lists into local entities.
			NSArray *jsonLists = [jsonObject objectForKey: @"lists"];
			NSArray *lists = [self _twitterListsFromJSONObject: jsonLists];
			
			NSNumber *nextCursor = [jsonObject objectForKey: @"next_cursor"];
			
			NSDictionary *transformResult = [NSDictionary dictionaryWithObjectsAndKeys: 
				lists, 
				@"lists", 
				[nextCursor stringValue], 
				@"nextCursor", 
				nil];
			
			return transformResult;
		} 
		completionBlock: ^(FDURLResponse *response)
		{
			if (response.status == FDURLResponseStatusSucceed)
			{
				NSArray *lists = [response.content objectForKey: @"lists"];
				NSString *nextCursor = [response.content objectForKey: @"nextCursor"];
				
				completion(response.status, nil, lists, nextCursor);
			}
			else
			{
				completion(response.status, response.error, nil, nil);
			}
		}];
}

- (void)tweetsForListId: (NSString *)listId 
	maxTweetId: (NSString *)maxTweetId 
	account: (ACAccount *)account 
	completion: (void (^)(FDURLResponseStatus status, NSError *error, NSArray *tweets))completion
{
	// Create resource URL for list's statuses request.
	NSURL *resourceURL = [self _resourceURLForMethodName: @"lists/statuses"];
	
	// Create parameters for list's statuses request.
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] 
		initWithObjectsAndKeys: 
			listId, 
			@"list_id", 
			@"true", 
			@"include_entities", 
			@"true", 
			@"include_rts", 
			nil];
	
	[self _setMaxTweetId: maxTweetId 
		forParameters: parameters];
	
	// Create list's statuses request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: resourceURL 
		parameters: parameters];
	
	request.account = account;
	
	// Load list's statuses request
	[self _loadRequest: request 
		transformBlock: ^id(id jsonObject)
		{
			// Transform tweets into local entities.
			NSArray *tweets = [self _tweetsFromJSONObject: jsonObject];
			
			return tweets;
		} 
		completionBlock: ^(FDURLResponse *response)
		{
			if (response.status == FDURLResponseStatusSucceed)
			{
				completion(response.status, nil, response.content);
			}
			else
			{
				completion(response.status, response.error, nil);
			}
		}];
}

- (void)profileImageForScreenName: (NSString *)screenName 
	account: (ACAccount *)account 
	completion: (void (^)(FDURLResponseStatus status, NSError *error, UIImage *profileImage, NSURL *profileImageURL))completion
{
	// Create resource URL for profile image request.
	NSString *methodName = [NSString stringWithFormat: @"users/profile_image/%@", 
		screenName];
	
	NSURL *resourceURL = [self _resourceURLForMethodName: methodName];
	
	// Create parameters for profile image request.
	NSDictionary *parameters = [[NSDictionary alloc] 
		initWithObjectsAndKeys: 
			@"original", 
			@"size", 
			nil];
	
	// Create profile image request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: resourceURL 
		parameters: parameters];
	
	request.account = account;
	
	// Load profile image request.
	[self loadURLRequest: [request preparedURLRequest] 
		urlRequestType: FDURLRequestTypeImage 
		authorizationBlock: nil 
		progressBlock: nil 
		dataParserBlock: nil 
		transformBlock: nil 
		completionBlock: ^(FDURLResponse *response)
		{
			if (response.status == FDURLResponseStatusSucceed)
			{
				completion(response.status, nil, response.content, [response.rawURLResponse URL]);
			}
			else
			{
				completion(response.status, response.error, nil, nil);
			}
		}];
}

- (void)tweetsForSearchQuery: (NSString *)query 
	tweetsPerPage: (unsigned int)tweetsPerPage 
	page: (unsigned int)page 
	maxTweetId: (NSString *)maxTweetId 
	account: (ACAccount *)account 
	completion: (void (^)(FDURLResponseStatus status, NSError *error, NSArray *tweets, NSString *maxTweetId))completion
{
	// Create resource URL for search request.
	NSString *resourceURLAsString = [NSString stringWithFormat: @"https://search.twitter.com/search.json"];
	
	// Create paramters for search request.
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] 
		initWithObjectsAndKeys: 
			@"true", 
			@"include_entities", 
			nil];
	
	if (FDIsEmpty(query) == NO)
	{
		[parameters setObject: query 
			forKey: @"q"];
	}
	
	[parameters setObject: [NSString stringWithFormat: @"%d", tweetsPerPage] 
		forKey: @"rpp"];
	
	[parameters setObject: [NSString stringWithFormat: @"%d", page] 
		forKey: @"page"];
	
	[self _setMaxTweetId: maxTweetId 
		forParameters: parameters];
	
	// Create search request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: [NSURL URLWithString: resourceURLAsString] 
		parameters: parameters];
	
	request.account = account;
	
	// Load search request.
	[self _loadRequest: request 
		transformBlock: ^id(id jsonObject)
		{
			// Transform tweets into local entities.
			NSArray *jsonResults = [jsonObject objectForKey: @"results"];
			
			NSMutableArray *tweets = [[NSMutableArray alloc] 
				initWithCapacity: [jsonResults count]];
			
			// NOTE: The structure of tweets returned from the search API differ than those from the REST API
			for (NSDictionary *jsonTweet in jsonResults)
			{
				FDTweet *tweet = [[FDTweet alloc] 
					init];
				
				NSString *tweetId = [jsonTweet objectForKey: @"id_str"];
				NSString *text = [jsonTweet objectForKey: @"text"];
				
				NSString *jsonDate = [jsonTweet objectForKey: @"created_at"];
				NSDate *creationDate = [_searchDateFormatter dateFromString: jsonDate];
				
				tweet.tweetId = tweetId;
				tweet.text = text;
				tweet.creationDate = creationDate;
				
				NSDictionary *entities = [jsonTweet objectForKey: @"entities"];
				
				NSArray *jsonURLs = [entities objectForKey: @"urls"];
				
				for (NSDictionary *jsonURL in jsonURLs)
				{
					NSString *rawURLAsString = [jsonURL nonNullObjectForKey: @"url"];
					NSString *displayURLAsString = [jsonURL nonNullObjectForKey: @"display_url"];
					NSString *expandedURLAsString = [jsonURL nonNullObjectForKey: @"expanded_url"];
					
					FDTwitterURL *url = [[FDTwitterURL alloc] 
						init];
					
					url.rawURL = [NSURL URLWithString: rawURLAsString];
					url.displayURL = [NSURL URLWithString: displayURLAsString];
					url.expandedURL = [NSURL URLWithString: expandedURLAsString];
					
					[tweet.urls addObject: url];
				}
				
				// NOTE: Users returned from the search API are lighter than user objects returned from the REST API.
				FDTwitterUser *user = [[FDTwitterUser alloc] 
					init];
				
				NSString *userId = [jsonTweet objectForKey: @"from_user_id_str"];
				NSString *screenName = [jsonTweet objectForKey: @"from_user"];
				NSString *name = [jsonTweet objectForKey: @"from_user_name"];
				NSString *profileImageURLAsString = [jsonTweet objectForKey: @"profile_image_url"];
				
				user.userId = userId;
				user.screenName = screenName;
				user.name = name;
				user.profileImageURL = [NSURL URLWithString: profileImageURLAsString];
				
				tweet.user = user;
				
				[tweets addObject: tweet];
			}
			
			NSString *maxTweetId = [jsonObject objectForKey: @"max_id_str"];
			
			NSDictionary *transformResult = [NSDictionary dictionaryWithObjectsAndKeys: 
				tweets, 
				@"tweets", 
				maxTweetId, 
				@"maxTweetId", 
				nil];
			
			return transformResult;
		} 
		completionBlock: ^(FDURLResponse *response)
		{
			if (response.status == FDURLResponseStatusSucceed)
			{
				NSArray *tweets = [response.content objectForKey: @"tweets"];
				NSString *maxTweetId = [response.content objectForKey: @"maxTweetId"];
				
				completion(response.status, nil, tweets, maxTweetId);
			}
			else
			{
				completion(response.status, response.error, nil, nil);
			}
		}];
}


#pragma mark - Private Methods

- (NSURL *)_resourceURLForMethodName: (NSString *)methodName
{
	NSString *resourceURLAsString = [NSString stringWithFormat: @"https://api.twitter.com/1/%@.json", 
		methodName];
	
	NSURL *resourceURL = [NSURL URLWithString: resourceURLAsString];
	
	return resourceURL;
}

- (void)_setMaxTweetId: (NSString *)maxTweetId 
	forParameters: (NSMutableDictionary *)parameters
{
	if (FDIsEmpty(maxTweetId) == NO)
	{
		// Subtract one from the tweet id so that it cannot be included in the results of the request.
		long long lowerMaxTweetId = [maxTweetId longLongValue] - 1;
		
		[parameters setObject: [NSString stringWithFormat: @"%lld", lowerMaxTweetId]  
			forKey: @"max_id"];
	}
}

- (void)_loadRequest: (SLRequest *)request 
	transformBlock: (FDURLConnectionTransformBlock)transformBlock 
	completionBlock: (FDURLConnectionOperationCompletionBlock)completionBlock
{
	[self loadURLRequest: [request preparedURLRequest] 
		urlRequestType: FDURLRequestTypeJSON 
		authorizationBlock: nil 
		progressBlock: nil 
		dataParserBlock: nil 
		transformBlock: transformBlock 
		completionBlock: completionBlock];
}

- (FDTwitterUser *)_twitterUserFromJSONObject: (NSDictionary *)jsonObject
{
	NSString *userId = [jsonObject objectForKey: @"id_str"];
	NSString *screenName = [jsonObject objectForKey: @"screen_name"];
	NSString *name = [jsonObject objectForKey: @"name"];
	NSString *location = [jsonObject objectForKey: @"location"];
	NSString *urlAsString = [jsonObject objectForKey: @"url"];
	NSString *bio = [jsonObject objectForKey: @"description"];
	NSString *profileImageURLAsString = [jsonObject objectForKey: @"profile_image_url"];
	NSNumber *followingCount = [jsonObject objectForKey: @"friends_count"];
	NSNumber *followerCount = [jsonObject objectForKey: @"followers_count"];
	NSNumber *listedCount = [jsonObject objectForKey: @"listed_count"];
	NSString *followedByAuthenticatedUserAsString = [jsonObject objectForKey: @"following"];
	
	FDTwitterUser *twitterUser = [[FDTwitterUser alloc] 
		init];
	
	twitterUser.userId = userId;
	twitterUser.screenName = screenName;
	twitterUser.name = name;
	
	if (FDIsEmpty(location) == NO)
	{
		twitterUser.location = location;
	}
	
	if (FDIsEmpty(urlAsString) == NO)
	{
		twitterUser.url = [NSURL URLWithString: urlAsString];
	}
	
	if (FDIsEmpty(bio) == NO)
	{
		twitterUser.bio = bio;
	}
	
	twitterUser.profileImageURL = [NSURL URLWithString: profileImageURLAsString];
	twitterUser.followingCount = [followingCount unsignedIntValue];
	twitterUser.followerCount = [followerCount unsignedIntValue];
	twitterUser.listedCount = [listedCount unsignedIntValue];
	
	if (FDIsEmpty(followedByAuthenticatedUserAsString) == NO)
	{
		twitterUser.followedByAuthenticatedUser = [followedByAuthenticatedUserAsString boolValue];
	}
	
	return twitterUser;
}

- (FDTweet *)_tweetFromJSONObject: (NSDictionary *)jsonObject
{
	NSString *tweetId = [jsonObject objectForKey: @"id_str"];
	NSString *text = [jsonObject objectForKey: @"text"];
	NSString *creationDateAsString = [jsonObject objectForKey: @"created_at"];
	NSDate *creationDate = [_apiDateFormatter dateFromString: creationDateAsString];
	BOOL favourited = [[jsonObject objectForKey: @"favorited"] 
		boolValue];
	BOOL retweeted = [[jsonObject objectForKey: @"retweeted"] 
		boolValue];
	NSNumber *retweetCount = [jsonObject objectForKey: @"retweet_count"];
	NSDictionary *jsonUser = [jsonObject objectForKey: @"user"];
	FDTwitterUser *user = [self _twitterUserFromJSONObject: jsonUser];
	
	FDTweet *tweet = [[FDTweet alloc] 
		init];
	
	tweet.tweetId = tweetId;
	tweet.text = text;
	tweet.creationDate = creationDate;
	tweet.favourited = favourited;
	tweet.retweeted = retweeted;
	tweet.retweetCount = [retweetCount unsignedIntValue];
	tweet.user = user;
	
	NSDictionary *entities = [jsonObject objectForKey: @"entities"];
	
	NSArray *jsonURLs = [entities objectForKey: @"urls"];
	
	for (NSDictionary *jsonURL in jsonURLs)
	{
		NSString *rawURLAsString = [jsonURL nonNullObjectForKey: @"url"];
		NSString *displayURLAsString = [jsonURL nonNullObjectForKey: @"display_url"];
		NSString *expandedURLAsString = [jsonURL nonNullObjectForKey: @"expanded_url"];
		
		FDTwitterURL *url = [[FDTwitterURL alloc] 
			init];
		
		url.rawURL = [NSURL URLWithString: rawURLAsString];
		url.displayURL = [NSURL URLWithString: displayURLAsString];
		url.expandedURL = [NSURL URLWithString: expandedURLAsString];
		
		[tweet.urls addObject: url];
	}
	
	return tweet;
}

- (FDTwitterList *)_twitterListFromJSONObject: (NSDictionary *)jsonObject
{
	NSString *listId = [jsonObject objectForKey: @"id_str"];
	NSString *name = [jsonObject objectForKey: @"name"];
	NSString *description = [jsonObject objectForKey: @"description"];
	NSNumber *memberCount = [jsonObject objectForKey: @"member_count"];
	NSNumber *subscriberCount = [jsonObject objectForKey: @"subscriber_count"];
	NSDictionary *jsonUser = [jsonObject objectForKey: @"user"];
	FDTwitterUser *user = [self _twitterUserFromJSONObject: jsonUser];
	
	FDTwitterList *list = [[FDTwitterList alloc] 
		init];
	
	list.listId = listId;
	list.name = name;
	list.listDescription = description;
	list.memberCount = [memberCount unsignedIntValue];
	list.subscriberCount = [subscriberCount unsignedIntValue];
	list.creator = user;
	
	return list;
}

- (NSArray *)_twitterUsersFromJSONObject: (NSArray *)jsonObject
{
	NSMutableArray *twitterUsers = [[NSMutableArray alloc] 
		initWithCapacity: [jsonObject count]];
	
	for (NSDictionary *jsonUser in jsonObject)
	{
		FDTwitterUser *twitterUser = [self _twitterUserFromJSONObject: jsonUser];
		
		[twitterUsers addObject: twitterUser];
	}
	
	return twitterUsers;
}

- (NSArray *)_tweetsFromJSONObject: (NSArray *)jsonObject
{
	NSMutableArray *tweets = [[NSMutableArray alloc] 
		initWithCapacity: [jsonObject count]];
	
	for (NSDictionary *jsonTweet in jsonObject)
	{
		FDTweet *tweet = [self _tweetFromJSONObject: jsonTweet];
		
		[tweets addObject: tweet];
	}
	
	return tweets;
}

- (NSArray *)_twitterListsFromJSONObject: (NSArray *)jsonObject
{
	NSMutableArray *twitterLists = [[NSMutableArray alloc] 
		initWithCapacity: [jsonObject count]];
	
	for (NSDictionary *jsonList in jsonObject)
	{
		FDTwitterList *twitterList = [self _twitterListFromJSONObject: jsonList];
		
		[twitterLists addObject: twitterList];
	}
	
	return twitterLists;
}


@end