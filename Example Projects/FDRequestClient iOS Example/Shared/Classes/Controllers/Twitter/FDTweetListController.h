#import "FDInfiniteTableView.h"


#pragma mark Class Interface

@interface FDTweetListController : UIViewController<
	FDInfiniteTableViewDataSource, 
	UITableViewDelegate>


#pragma mark -
#pragma mark Properties

@property (nonatomic, readonly, strong) FDInfiniteTableView *infiniteTableView;

@property (nonatomic, readonly) NSArray *tweets;


#pragma mark -
#pragma mark Instance Methods

- (void)addTweets: (NSArray *)tweets 
	withRowAnimation: (UITableViewRowAnimation)rowAnimation;
- (void)clearTweetsWithRowAnimation: (UITableViewRowAnimation)rowAnimation;
- (void)loadTweets;


@end // @interface FDTweetListController