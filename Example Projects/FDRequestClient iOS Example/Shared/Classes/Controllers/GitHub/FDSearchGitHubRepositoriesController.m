#import "FDSearchGitHubRepositoriesController.h"
#import "FDGitHubAPIClient.h"
#import "FDGitHubRepositoryDetailController.h"


#pragma mark Constants

#define NoMorePages	-1

static NSString * const CellIdentifier = @"SearchGitHubRepositoriesCellIdentifier";


#pragma mark -
#pragma mark Class Extension

@interface FDSearchGitHubRepositoriesController ()

- (void)_initializeSearchGitHubRepositoriesController;


@end // @interface FDSearchGitHubRepositoriesController ()


#pragma mark -
#pragma mark Class Definition

@implementation FDSearchGitHubRepositoriesController
{
	@private __strong FDGitHubAPIClient *_gitHubAPIClient;
	@private int _currentPage;
}


#pragma mark -
#pragma mark Constructors

- (id)initWithDefaultNibName
{
	// Abort if base initializer fails.
	if ((self = [self initWithNibName: @"FDSearchGitHubRepositoriesView" 
		bundle: nil]) == nil)
	{
		return nil;
	}

	// Return initialized instance.
	return self;
}

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
	[self _initializeSearchGitHubRepositoriesController];
	
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
	[self _initializeSearchGitHubRepositoriesController];
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Overridden Methods

- (void)performSearchWithQuery: (NSString *)query
{
	_currentPage = 1;
	
	[_gitHubAPIClient repositoriesForSearchQuery: self.searchBar.text 
		page: _currentPage++ 
		completion: ^(FDURLResponseStatus status, NSError *error, NSArray *repositories)
		{
			[self.infiniteTableView doneLoading];
			
			if ([repositories count] < 100)
			{
				_currentPage = NoMorePages;
			}
			
			[self addSearchResults: repositories 
				withRowAnimation: UITableViewRowAnimationNone];
		}];
}

- (void)loadMoreSearchResults
{
	[_gitHubAPIClient repositoriesForSearchQuery: self.searchBar.text 
		page: _currentPage++ 
		completion: ^(FDURLResponseStatus status, NSError *error, NSArray *repositories)
		{
			if ([repositories count] < 100)
			{
				_currentPage = NoMorePages;
			}
			
			[self addSearchResults: repositories 
				withRowAnimation: UITableViewRowAnimationAutomatic];
		}];
}


#pragma mark -
#pragma mark Private Methods

- (void)_initializeSearchGitHubRepositoriesController
{
	// Initialize instance variables.
	_gitHubAPIClient = [[FDGitHubAPIClient alloc] 
		init];
	_currentPage = 1;
	
	// Set controller's title.
	self.title = @"Search GitHub Repos";
}


#pragma mark -
#pragma mark FDInfiniteTableViewDataSource Methods

- (BOOL)canLoadDataForInfiniteTableView: (FDInfiniteTableView *)infiniteTableView
{
	BOOL canLoadData = NO;
	
	if (infiniteTableView == self.infiniteTableView)
	{
		if ([super canLoadDataForInfiniteTableView: infiniteTableView] == YES 
			&& _currentPage != NoMorePages)
		{
			canLoadData = YES;
		}
	}
	
	return canLoadData;
}


#pragma mark -
#pragma mark UITableViewDataSource Methods

- (UITableViewCell *)tableView: (UITableView *)tableView 
	cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	
	if (tableView == self.infiniteTableView)
	{
		cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
		
		if (cell == nil)
		{
			cell = [[UITableViewCell alloc] 
				initWithStyle: UITableViewCellStyleSubtitle 
					reuseIdentifier: CellIdentifier];
		}
		
		FDGitHubRepository *gitHubRepository = [self.searchResults objectAtIndex: indexPath.row];
		
		cell.textLabel.text = [NSString stringWithFormat: @"%@ / %@", 
			gitHubRepository.owner, 
			gitHubRepository.name];
		cell.detailTextLabel.text = gitHubRepository.repoDescription;
	}
	
	return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate Methods

- (void)tableView: (UITableView *)tableView 
	didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath: indexPath 
		animated: YES];
	
	if (tableView == self.infiniteTableView)
	{
		FDGitHubRepository *gitHubRepository = [self.searchResults objectAtIndex: indexPath.row];
		
		FDGitHubRepositoryDetailController *gitHubRepositoryDetailController = [[FDGitHubRepositoryDetailController alloc] 
			initWithDefaultNibName];
		
		gitHubRepositoryDetailController.gitHubRepository = gitHubRepository;
		
		[self.navigationController pushViewController: gitHubRepositoryDetailController 
			animated: YES];
	}
}


@end // @implementation FDSearchGitHubRepositoriesController