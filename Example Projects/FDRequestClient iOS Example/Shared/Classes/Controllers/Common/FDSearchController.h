#import "FDInfiniteTableView.h"


#pragma mark Class Interface

@interface FDSearchController : UIViewController<
	FDInfiniteTableViewDataSource, 
	UITableViewDelegate, 
	UISearchBarDelegate>


#pragma mark - Properties

@property (nonatomic, strong) IBOutlet FDInfiniteTableView *infiniteTableView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@property (nonatomic, readonly) NSArray *searchResults;


#pragma mark - Instance Methods

- (void)addSearchResults: (NSArray *)searchResults 
	withRowAnimation: (UITableViewRowAnimation)rowAnimation;
- (void)clearSearchResultsWithRowAnimation: (UITableViewRowAnimation)rowAnimation;
- (void)performSearchWithQuery: (NSString *)query;
- (void)loadMoreSearchResults;


@end