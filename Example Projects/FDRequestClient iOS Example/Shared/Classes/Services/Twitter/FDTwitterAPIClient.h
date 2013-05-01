#import <Accounts/Accounts.h>
#import "FDTwitterUser.h"
#import "FDTweet.h"
#import "FDTwitterList.h"


#pragma mark Class Interface

@interface FDTwitterAPIClient : FDRequestClient


#pragma mark - Instance Methods

- (void)listsForUserId: (NSString *)userId 
	account: (ACAccount *)account 
	completion: (void (^)(FDURLResponseStatus status, NSError *error, NSArray *lists))completion;

- (void)tweetsForListId: (NSString *)listId 
	maxTweetId: (NSString *)maxTweetId 
	account: (ACAccount *)account 
	completion: (void (^)(FDURLResponseStatus status, NSError *error, NSArray *tweets))completion;

- (void)tweetsForSearchQuery: (NSString *)query 
	count: (unsigned int)count 
	maxTweetId: (NSString *)maxTweetId 
	account: (ACAccount *)account 
	completion: (void (^)(FDURLResponseStatus status, NSError *error, NSArray *tweets, NSString *maxTweetId))completion;


@end