#import "FDInfiniteTableViewDataSource.h"


#pragma mark Class Interface

@interface FDInfiniteTableView : UITableView


#pragma mark - Properties

@property (nonatomic, weak) IBOutlet id<FDInfiniteTableViewDataSource> dataSource;


#pragma mark - Instance Methods

- (void)showLoadingView;
- (void)doneLoading;


@end