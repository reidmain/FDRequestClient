#import "FDInfiniteTableViewDataSource.h"


#pragma mark Class Interface

@interface FDInfiniteTableView : UITableView


#pragma mark -
#pragma mark Properties

@property (nonatomic, assign) IBOutlet id<FDInfiniteTableViewDataSource> dataSource;


#pragma mark -
#pragma mark Instance Methods

- (void)showLoadingView;
- (void)doneLoading;


@end // @interface FDInfiniteTableView