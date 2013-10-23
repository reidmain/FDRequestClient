#import "FDExampleListController.h"
@import Social;
#import "FDSearchTweetsController.h"
#import "FDSearchGitHubRepositoriesController.h"
#import "UIView+Layout.h"


#pragma mark Constants

static NSString * const Row_SearchTweets = @"Search for Tweets";
static NSString * const Row_SearchGitHubRepos = @"Search GitHub Repositories";
static NSString * const CellIdentifier = @"CellIdentifier";


#pragma mark - Class Extension

@interface FDExampleListController ()

- (void)_initializeExampleListController;


@end


#pragma mark - Class Definition

@implementation FDExampleListController
{
	@private __strong NSMutableArray *_rows;
	@private __strong UITableView *_tableView;
	@private __strong ACAccountStore *_twitterAccountStore;
	@private __strong ACAccountType *_twitterAccountType;
}


#pragma mark - Constructors

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


#pragma mark - Destructor

- (void)dealloc 
{
	// nil out delegates of any instance variables.
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
}


#pragma mark - Overridden Methods

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


#pragma mark - Private Methods

- (void)_initializeExampleListController
{
	// Initialize instance variables.
	_rows = [[NSMutableArray alloc] 
		initWithObjects: 
			Row_SearchTweets, 
			Row_SearchGitHubRepos, 
			nil];
	_twitterAccountStore = [[ACAccountStore alloc] init];
	_twitterAccountType = [_twitterAccountStore accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierTwitter];
	
	// Set controller's title.
	self.title = @"Examples";
}


#pragma mark - UITableViewDataSource Methods

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


#pragma mark - UITableViewDelegate Methods

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
			// v1.1 of the Twitter API requires a account for all requests so ask the user to access their Twitter accounts.
			
			// If a tweet is not able to be sent display an alert to the user.
			if ([SLComposeViewController isAvailableForServiceType: SLServiceTypeTwitter] == NO)
			{
				// If a SLComposeViewController is presented with all of its subviews removed when the user cannot tweet a alert view will be displayed with a button that will take users directly to Settings so they can setup a Twitter account.
				SLComposeViewController *composeTweetController = [SLComposeViewController composeViewControllerForServiceType: SLServiceTypeTwitter];
				
				[composeTweetController.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
				
				[[UIApplication sharedApplication].keyWindow.rootViewController presentViewController: composeTweetController 
					animated: NO 
					completion: nil];
			}
			// Otherwise, request access to the user's Twitter accounts.
			else
			{
				[_twitterAccountStore requestAccessToAccountsWithType: _twitterAccountType 
					options: nil 
					completion: ^(BOOL granted, NSError *error)
						{
							// NOTE: The completion handler is called on an arbitrary queue.
							[self performBlockOnMainThread:^
								{
									if (granted == YES)
									{
										NSArray *twitterAccounts = [_twitterAccountStore accountsWithAccountType: _twitterAccountType];
										ACAccount *twitterAccount = [twitterAccounts lastObject];
										
										FDSearchTweetsController *searchTweetsController = [[FDSearchTweetsController alloc] 
											initWithTwitterAccount: twitterAccount];
										
										[_delegate exampleListController: self 
											showViewController: searchTweetsController];
									}
								}];
						}];
			}
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


@end