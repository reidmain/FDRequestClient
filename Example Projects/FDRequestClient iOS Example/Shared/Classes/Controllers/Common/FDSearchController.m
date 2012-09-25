#import "FDSearchController.h"
#import "FDNullOrEmpty.h"
#import "UIView+Layout.h"


#pragma mark Class Extension

@interface FDSearchController ()

- (void)_initializeSearchController;


@end // @interface FDSearchController ()


#pragma mark -
#pragma mark Class Definition

@implementation FDSearchController
{
	@private __strong FDInfiniteTableView *_infiniteTableView;
	@private __strong UISearchBar *_searchBar;
	
	@private __strong NSMutableArray *_searchResults;
}


#pragma mark -
#pragma mark Properties

@synthesize infiniteTableView = _infiniteTableView;
@synthesize searchBar = _searchBar;

@synthesize searchResults = _searchResults;


#pragma mark -
#pragma mark Constructors

- (id)initWithNibName: (NSString *)nibName 
    bundle:(NSBundle *)bundle
{
	// Abort if base initializer fails.
	if ((self = [super initWithNibName: nibName 
        bundle: bundle]) == nil)
	{
		return nil;
	}
	
	// Initialize controller.
	[self _initializeSearchController];
	
	// Return initialized instance.
	return self;
}

- (id)initWithCoder: (NSCoder *)coder
{
	// Abort if base initializer fails.
	if ((self = [super initWithCoder: coder]) == nil)
	{
		return nil;
	}
	
	// Initialize controller.
	[self _initializeSearchController];
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc 
{
	// nil out delegates of any instance variables.
	_infiniteTableView.delegate = nil;
	_infiniteTableView.dataSource = nil;
	_searchBar.delegate = nil;
}


#pragma mark -
#pragma mark Public Methods

- (void)addSearchResults: (NSArray *)searchResults 
	withRowAnimation: (UITableViewRowAnimation)rowAnimation
{
	if (rowAnimation == UITableViewRowAnimationNone)
	{
		[_searchResults addObjectsFromArray: searchResults];
		[_infiniteTableView reloadData];
	}
	else
	{
		NSMutableArray *rowsToInsert = [[NSMutableArray alloc] 
			initWithCapacity: [searchResults count]];
		
		NSUInteger startingIndex = 0;
		if (FDIsEmpty(_searchResults) == NO)
		{
			startingIndex = [_searchResults count];
		}
		
		for (NSUInteger i=startingIndex; i < [_searchResults count] + [searchResults count]; i++)
		{
			NSIndexPath *indexPathToInsert = [NSIndexPath indexPathForRow: i inSection: 0];
			
			[rowsToInsert addObject: indexPathToInsert];
		}
		
		[_searchResults addObjectsFromArray: searchResults];
		
		[_infiniteTableView insertRowsAtIndexPaths: rowsToInsert 
			withRowAnimation: rowAnimation];
	}
}

- (void)clearSearchResultsWithRowAnimation: (UITableViewRowAnimation)rowAnimation
{
	if (rowAnimation == UITableViewRowAnimationNone)
	{
		[_searchResults removeAllObjects];
		[_infiniteTableView reloadData];
	}
	else
	{
		NSMutableArray *rowsToDelete = [[NSMutableArray alloc] 
			initWithCapacity: [_searchResults count]];
		
		for (NSUInteger i=0; i < [_searchResults count]; i++)
		{
			NSIndexPath *indexPathToDelete = [NSIndexPath indexPathForRow: i inSection: 0];
			
			[rowsToDelete addObject: indexPathToDelete];
		}
		
		[_searchResults removeAllObjects];
		
		[_infiniteTableView deleteRowsAtIndexPaths: rowsToDelete 
			withRowAnimation: rowAnimation];
	}
}

- (void)performSearchWithQuery: (NSString *)query;
{
	// Abstract method.
}

- (void)loadMoreSearchResults
{
	// Abstract method.
}


#pragma mark -
#pragma mark Overridden Methods

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidLoad
{
	// Call base implementation.
	[super viewDidLoad];
	
	// Create infinite table view if one does not exist.
	if (_infiniteTableView == nil)
	{
		_infiniteTableView = [[FDInfiniteTableView alloc] 
			initWithFrame: CGRectMake(
					0.0f, 
					0.0f, 
					self.view.width, 
					self.view.height) 
				style: UITableViewStylePlain];
		
		_infiniteTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth 
			| UIViewAutoresizingFlexibleHeight;
		
		_infiniteTableView.dataSource = self;
		_infiniteTableView.delegate = self;
		
		[self.view addSubview: _infiniteTableView];
	}
	
	// Create search bar if one does not exist.
	if (_searchBar == nil)
	{
		_searchBar = [[UISearchBar alloc] 
			init];
		
		_searchBar.delegate = self;
		
		_infiniteTableView.tableHeaderView = _searchBar;
	}
}


#pragma mark -
#pragma mark Private Methods

- (void)_initializeSearchController
{
	// Initialize instance variables.
	_searchResults = [[NSMutableArray alloc] 
		init];
}


#pragma mark -
#pragma mark FDInfiniteTableViewDataSource Methods

- (BOOL)canLoadDataForInfiniteTableView: (FDInfiniteTableView *)infiniteTableView
{
	BOOL canLoadData = NO;
	
	if (infiniteTableView == _infiniteTableView)
	{
		if ([_searchResults count] > 0)
		{
			canLoadData = YES;
		}
	}
	
	return canLoadData;
}

- (void)loadDataForInfiniteTableView:(FDInfiniteTableView *)infiniteTableView
{
	if (infiniteTableView == _infiniteTableView)
	{
		[self loadMoreSearchResults];
	}
}


#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView: (UITableView *)tableView 
	numberOfRowsInSection: (NSInteger)section
{
	NSInteger numberOfRows = 0;
	
	if (tableView == _infiniteTableView)
	{
		numberOfRows = [_searchResults count];
	}
	
	return numberOfRows;
}

- (UITableViewCell *)tableView: (UITableView *)tableView 
	cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
	// Abstract method.
	return nil;
}


#pragma mark -
#pragma mark UISearchBarDelegate Methods

- (void)searchBarSearchButtonClicked: (UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	
	[self clearSearchResultsWithRowAnimation: UITableViewRowAnimationAutomatic];
	
	[self performSearchWithQuery: searchBar.text];
	
	[_infiniteTableView showLoadingView];
}


@end // @implementation FDSearchController