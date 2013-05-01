#import "FDTweet.h"
#import <Accounts/Accounts.h>


#pragma mark Class Interface

@interface FDTweetDetailsController : UIViewController<
	UITableViewDataSource, 
	UITableViewDelegate>


#pragma mark - Constructors

- (id)initWithTweet: (FDTweet *)tweet 
	twitterAccount: (ACAccount *)twitterAccount;


@end