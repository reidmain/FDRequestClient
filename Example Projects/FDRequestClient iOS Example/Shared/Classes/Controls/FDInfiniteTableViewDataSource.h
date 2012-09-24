#pragma mark Forward Declarations

@class FDInfiniteTableView;


#pragma mark -
#pragma mark Enumerations


#pragma mark -
#pragma mark Protocol

@protocol FDInfiniteTableViewDataSource<UITableViewDataSource>


#pragma mark -
#pragma mark Required Methods

@required

//- (void)didFinish;


#pragma mark -
#pragma mark Optional Methods

@optional

- (BOOL)canLoadDataForInfiniteTableView: (FDInfiniteTableView *)infiniteTableView;
- (void)loadDataForInfiniteTableView: (FDInfiniteTableView *)infiniteTableView;


@end // @protocol FDInfiniteTableViewDataSource