#import "FDTweetListController.h"


#pragma mark Class Interface

@interface FDSearchTweetsController : FDTweetListController<
	UISearchBarDelegate>


#pragma mark - Constructors

- (id)initWithTwitterAccount: (ACAccount *)twitterAccount;


@end