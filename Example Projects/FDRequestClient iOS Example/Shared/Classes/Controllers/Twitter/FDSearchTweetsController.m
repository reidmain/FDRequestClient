#import "FDSearchTweetsController.h"
#import "FDTwitterAPIClient.h"
#import "FDNullOrEmpty.h"
#import "UIView+Layout.h"


#pragma mark Class Extension

@interface FDSearchTweetsController ()

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;


- (void)_initializeSearchTweetsController;


@end // @interface FDSearchTweetsController ()


#pragma mark -
#pragma mark Class Definition

@implementation FDSearchTweetsController
{
	@private __strong UISearchBar *_searchBar;
	
	@private __strong FDTwitterAPIClient *_twitterAPIClient;
	@private unsigned int _currentPage;
	@private __strong NSString *_maxTweetId;
}


#pragma mark -
#pragma mark Properties

@synthesize searchBar = _searchBar;


#pragma mark -
#pragma mark Constructors

- (id)initWithDefaultNibName
{
	// Abort if base initializer fails.
	if ((self = [self initWithNibName: @"FDSearchTweetsView" 
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
	[self _initializeSearchTweetsController];
	
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
	[self _initializeSearchTweetsController];
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc 
{
	// nil out delegates of any instance variables.
	_searchBar.delegate = nil;
}


#pragma mark -
#pragma mark Overridden Methods

- (void)loadTweets
{
	// Call base implementation.
	[super loadTweets];
	
	[_twitterAPIClient tweetsForSearchQuery: _searchBar.text 
		tweetsPerPage: 50 
		page: _currentPage++ 
		maxTweetId: _maxTweetId 
		account: nil 
		completion: ^(FDURLResponseStatus status, NSError *error, NSArray *tweets, NSString *maxTweetId)
		{
			[self.infiniteTableView doneLoading];
			
			if (status == FDURLResponseStatusSucceed)
			{
				_maxTweetId = [maxTweetId copy];
				
				[self addTweets: tweets 
					withRowAnimation: UITableViewRowAnimationAutomatic];
			}
		}];
}


#pragma mark -
#pragma mark Private Methods

- (void)_initializeSearchTweetsController
{
	// Initialize instance variables.
	_twitterAPIClient = [[FDTwitterAPIClient alloc] 
		init];
	_currentPage = 1;
	_maxTweetId = nil;
	
	// Set controller's title.
	self.title = @"Search Tweets";
}


#pragma mark -
#pragma mark UISearchBarDelegate Methods

- (void)searchBarSearchButtonClicked: (UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	
	_currentPage = 1;
	_maxTweetId = nil;
	
	[self clearTweetsWithRowAnimation: UITableViewRowAnimationAutomatic];
	
	[self loadTweets];
}


@end // @implementation FDSearchTweetsController