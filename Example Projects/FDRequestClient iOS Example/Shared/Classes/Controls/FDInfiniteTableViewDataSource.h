#pragma mark Forward Declarations

@class FDInfiniteTableView;


#pragma mark - Enumerations


#pragma mark - Protocol

@protocol FDInfiniteTableViewDataSource<UITableViewDataSource>


#pragma mark - Required Methods

@required

//- (void)didFinish;


#pragma mark - Optional Methods

@optional

- (BOOL)canLoadDataForInfiniteTableView: (FDInfiniteTableView *)infiniteTableView;
- (void)loadDataForInfiniteTableView: (FDInfiniteTableView *)infiniteTableView;


@end