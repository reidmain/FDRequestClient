#import "FDTweetListController.h"
#import "FDTwitterList.h"


#pragma mark Class Interface

@interface FDTwitterListTweetsController : FDTweetListController


#pragma mark - Constructors

- (id)initWithTwitterList: (FDTwitterList *)twitterList 
	twitterAccount: (ACAccount *)twitterAccount;


@end