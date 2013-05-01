#import "FDInfiniteTableView.h"


#pragma mark Class Interface

@interface FDTweetListController : UIViewController<
	FDInfiniteTableViewDataSource, 
	UITableViewDelegate>


#pragma mark - Properties

@property (nonatomic, strong, readonly) FDInfiniteTableView *infiniteTableView;

@property (nonatomic, readonly) NSArray *tweets;


#pragma mark - Instance Methods

- (void)addTweets: (NSArray *)tweets 
	withRowAnimation: (UITableViewRowAnimation)rowAnimation;
- (void)clearTweetsWithRowAnimation: (UITableViewRowAnimation)rowAnimation;
- (void)loadTweets;


@end