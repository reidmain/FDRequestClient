#import "FDExampleListController.h"
#import "FDSearchTweetsController.h"
#import "FDSearchGitHubRepositoriesController.h"
#import "UIView+Layout.h"


#pragma mark Constants

static NSString * const Row_SearchTweets = @"Search for Tweets";
static NSString * const Row_SearchGitHubRepos = @"Search GitHub Repositories";
static NSString * const CellIdentifier = @"CellIdentifier";


#pragma mark -
#pragma mark Class Extension

@interface FDExampleListController ()
{
	@private __strong NSMutableArray *_rows;
	@private __strong UITableView *_tableView;
}


- (void)_initializeExampleListController;


@end // @interface FDExampleListController ()


#pragma mark -
#pragma mark Class Definition

@implementation FDExampleListController


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
	[self _initializeExampleListController];
	
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
	[self _initializeExampleListController];
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc 
{
	// nil out delegates of any instance variables.
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
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
	
	// Create table view and add it to the controller's view.
	if (_tableView == nil)
	{
		_tableView = [[UITableView alloc] 
			initWithFrame: CGRectMake(
					0.0f, 
					0.0f, 
					self.view.width, 
					self.view.height) 
				style: UITableViewStyleGrouped];
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth 
			| UIViewAutoresizingFlexibleHeight;
		
		_tableView.dataSource = self;
		_tableView.delegate = self;
		
		[self.view addSubview: _tableView];
	}
}


#pragma mark -
#pragma mark Private Methods

- (void)_initializeExampleListController
{
	// Initialize instance variables.
	_rows = [[NSMutableArray alloc] 
		initWithObjects: 
			Row_SearchTweets, 
			Row_SearchGitHubRepos, 
			nil];
	
	// Set controller's title.
	self.title = @"Examples";
}


#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView: (UITableView *)tableView 
	numberOfRowsInSection: (NSInteger)section
{
	NSInteger numberOfRows = 0;
	
	if (tableView == _tableView)
	{
		numberOfRows = [_rows count];
	}
	
	return numberOfRows;
}

- (UITableViewCell *)tableView: (UITableView *)tableView 
	cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
	
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] 
			initWithStyle: UITableViewCellStyleDefault 
				reuseIdentifier: CellIdentifier];
	}
	
	NSString *row = [_rows objectAtIndex: indexPath.row];
	
	cell.textLabel.text = row;
	
	return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate Methods

- (void)tableView: (UITableView *)tableView 
	didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath: indexPath 
		animated: YES];
	
	if (tableView == _tableView)
	{
		UIViewController *viewController = nil;
		
		NSString *row = [_rows objectAtIndex: indexPath.row];
		
		if (row == Row_SearchTweets)
		{
			viewController = [[FDSearchTweetsController alloc] 
				initWithDefaultNibName];
		}
		else if (row == Row_SearchGitHubRepos)
		{
			viewController = [[FDSearchGitHubRepositoriesController alloc] 
				initWithDefaultNibName];
		}
		
		if (viewController != nil)
		{
			[_delegate exampleListController: self 
				showViewController: viewController];
		}
	}
}


@end // @implementation FDExampleListController