#import "FDRequestClient.h"
#import <Accounts/Accounts.h>
#import "FDTwitterUser.h"
#import "FDTweet.h"
#import "FDTwitterList.h"


#pragma mark Class Interface

@interface FDTwitterAPIClient : FDRequestClient


#pragma mark -
#pragma mark Instance Methods

- (void)listsForUserId: (NSString *)userId 
	cursor: (NSString *)cursor 
	account: (ACAccount *)account 
	completion: (void (^)(FDURLResponseStatus status, NSError *error, NSArray *lists, NSString *nextCursor))completion;

- (void)tweetsForListId: (NSString *)listId 
	maxTweetId: (NSString *)maxTweetId 
	account: (ACAccount *)account 
	completion: (void (^)(FDURLResponseStatus status, NSError *error, NSArray *tweets))completion;

- (void)profileImageForScreenName: (NSString *)screenName 
	account: (ACAccount *)account 
	completion: (void (^)(FDURLResponseStatus status, NSError *error, UIImage *profileImage, NSURL *profileImageURL))completion;

- (void)tweetsForSearchQuery: (NSString *)query 
	tweetsPerPage: (unsigned int)tweetsPerPage 
	page: (unsigned int)page 
	maxTweetId: (NSString *)maxTweetId 
	account: (ACAccount *)account 
	completion: (void (^)(FDURLResponseStatus status, NSError *error, NSArray *tweets, NSString *maxTweetId))completion;


@end // @interface FDTwitterAPIClient