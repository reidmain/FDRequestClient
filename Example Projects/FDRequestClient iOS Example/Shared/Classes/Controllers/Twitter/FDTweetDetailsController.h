#import "FDTweet.h"
@import Accounts;


#pragma mark Class Interface

@interface FDTweetDetailsController : UIViewController<
	UITableViewDataSource, 
	UITableViewDelegate>


#pragma mark - Constructors

- (id)initWithTweet: (FDTweet *)tweet 
	twitterAccount: (ACAccount *)twitterAccount;


@end