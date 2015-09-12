#import "FDTwitterAPIClient.h"
@import Social;


#pragma mark Class Extension

@interface FDTwitterAPIClient ()

- (NSURL *)_resourceURLForMethodName: (NSString *)methodName;

- (void)_setMaxTweetId: (NSString *)maxTweetId 
	forParameters: (NSMutableDictionary *)parameters;

- (void)_loadRequest: (SLRequest *)request 
	transformBlock: (FDRequestClientTaskTransformBlock)transformBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;

- (FDTwitterUser *)_twitterUserFromJSONObject: (NSDictionary *)jsonObject;
- (FDTweet *)_tweetFromJSONObject: (NSDictionary *)jsonObject;
- (FDTwitterList *)_twitterListFromJSONObject: (NSDictionary *)jsonObject;

- (NSArray *)_twitterUsersFromJSONObject: (NSArray *)jsonObject;
- (NSArray *)_tweetsFromJSONObject: (NSArray *)jsonObject;
- (NSArray *)_twitterListsFromJSONObject: (NSArray *)jsonObject;


@end


#pragma mark - Class Variables

static NSDateFormatter *_apiDateFormatter;


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
		
		classInitialized = YES;
	}
}


#pragma mark - Public Methods

- (void)listsForUserId: (NSString *)userId 
	account: (ACAccount *)account 
	completion: (void (^)(FDURLResponseStatus status, NSError *error, NSArray *lists))completion
{
	// Create resource URL for lists request.
	NSURL *resourceURL = [self _resourceURLForMethodName: @"lists/list"];
	
	// Create parameters for lists request.
	NSDictionary *parameters = @{ 
		@"user_id" : userId, 
		@"reverse" : @"true" };
	
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
			NSArray *lists = [self _twitterListsFromJSONObject: jsonObject];
			
			return lists;
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

- (void)tweetsForSearchQuery: (NSString *)query 
	count: (unsigned int)count 
	maxTweetId: (NSString *)maxTweetId 
	account: (ACAccount *)account 
	completion: (void (^)(FDURLResponseStatus status, NSError *error, NSArray *tweets, NSString *maxTweetId))completion
{
	// Create resource URL for search request.
	NSURL *resourceURL = [self _resourceURLForMethodName: @"search/tweets"];
	
	// Create paramters for search request.
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] 
		initWithObjectsAndKeys: 
			query, @"q", 
			[NSString stringWithFormat:@"%u", count], @"count", 
			nil];
	
	[self _setMaxTweetId: maxTweetId 
		forParameters: parameters];
	
	// Create search request.
	SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter 
		requestMethod: SLRequestMethodGET 
		URL: resourceURL 
		parameters: parameters];
	
	request.account = account;
	
	// Load search request.
	[self _loadRequest: request 
		transformBlock: ^id(id jsonObject)
		{
			// Transform tweets into local entities.
			NSArray *jsonTweets = [jsonObject objectForKey: @"statuses"];
			NSArray *tweets = [self _tweetsFromJSONObject: jsonTweets];
			
			NSDictionary *searchMetadata = [jsonObject objectForKey: @"search_metadata"];
			NSString *maxTweetId = [searchMetadata objectForKey: @"max_id_str"];
			
			NSDictionary *transformResult = @{ 
				@"tweets" : tweets, 
				@"maxTweetId" : maxTweetId };
			
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
	NSString *resourceURLAsString = [NSString stringWithFormat: @"https://api.twitter.com/1.1/%@.json", 
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
	transformBlock: (FDRequestClientTaskTransformBlock)transformBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock
{
	[self loadURLRequest: [request preparedURLRequest] 
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
		NSString *rawURLAsString = [jsonURL fd_nonNullObjectForKey: @"url"];
		NSString *displayURLAsString = [jsonURL fd_nonNullObjectForKey: @"display_url"];
		NSString *expandedURLAsString = [jsonURL fd_nonNullObjectForKey: @"expanded_url"];
		
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