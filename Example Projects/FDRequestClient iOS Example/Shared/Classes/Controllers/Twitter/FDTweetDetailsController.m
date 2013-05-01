#import "FDTweetDetailsController.h"
#import "FDTwitterAPIClient.h"
#import "FDTwitterListTweetsController.h"
#import "UIImageView+WebImage.h"
#import "UIView+Layout.h"


#pragma mark Constants

static NSString * const CellIdentifier = @"TweetDetailsCellIdentifier";


#pragma mark - Class Extension

@interface FDTweetDetailsController ()

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *tableHeaderView;
@property (nonatomic, strong) IBOutlet UIImageView *profileImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *screenNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *textLabel;
@property (nonatomic, strong) IBOutlet UIView *tableFooterView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) IBOutlet UILabel *noListsLabel;

- (void)_initializeTweetDetailsController;


@end


#pragma mark -
#pragma mark Class Definition

@implementation FDTweetDetailsController
{
	@private __strong FDTwitterAPIClient *_twitterAPIClient;
	@private BOOL _listsRequested;
	@private __strong NSMutableArray *_lists;
}


#pragma mark - Constructors

- (id)initWithDefaultNibName
{
	// Abort if base initializer fails.
	if ((self = [self initWithNibName: @"FDTweetDetailsView" 
		bundle: nil]) == nil)
	{
		return nil;
	}

	// Return initialized instance.
	return self;
}

- (id)initWithNibName: (NSString *)nibName 
    bundle: (NSBundle *)bundle
{
	// Abort if base initializer fails.
	if ((self = [super initWithNibName: nibName 
        bundle: bundle]) == nil)
	{
		return nil;
	}
	
	// Initialize controller.
	[self _initializeTweetDetailsController];
	
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
	[self _initializeTweetDetailsController];
	
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
	
	_nameLabel.text = _tweet.user.name;
	_screenNameLabel.text = [NSString stringWithFormat: @"@%@", 
		_tweet.user.screenName];
	_textLabel.text = _tweet.text;
	
	_profileImageView.layer.cornerRadius = 4.0f;
	_profileImageView.contentMode = UIViewContentModeScaleAspectFill;
	_profileImageView.clipsToBounds = YES;
	[_profileImageView loadImageFromURL: _tweet.user.profileImageURL 
		placeholderImage: [UIImage imageNamed:@"twitter_logo.png"]];
	
	[_textLabel sizeToFit];
	_tableHeaderView.height = _textLabel.yOrigin + _textLabel.height + _profileImageView.yOrigin;
	
	if (_listsRequested == YES 
		&& FDIsEmpty(_lists) == YES)
	{
		_noListsLabel.hidden = NO;
	}
	else
	{
		_noListsLabel.hidden = YES;
	}
}

- (void)viewDidAppear: (BOOL)animated
{
	// Call base implementation.
	[super viewDidAppear: animated];
	
	// Load Twitter lists for the user who created the tweet.
	if (_listsRequested == NO)
	{
		_tableView.tableFooterView = _tableFooterView;
		_noListsLabel.hidden = YES;
		[_activityIndicatorView startAnimating];
		
		[_twitterAPIClient listsForUserId: _tweet.user.userId 
			cursor: nil 
			account: nil 
			completion: ^(FDURLResponseStatus status, NSError *error, NSArray *lists, NSString *nextCursor)
			{
				if (status == FDURLResponseStatusSucceed)
				{
					[_activityIndicatorView stopAnimating];
					
					[_lists removeAllObjects];
					[_lists addObjectsFromArray: lists];
					
					if (FDIsEmpty(_lists) == YES)
					{
						_noListsLabel.hidden = NO;
					}
					else
					{
						_tableView.tableFooterView = nil;
						_noListsLabel.hidden = YES;
					}
					
					[_tableView reloadData];
				}
			}];
		
		_listsRequested = YES;
	}
}


#pragma mark - Private Methods

- (void)_initializeTweetDetailsController
{
	// Initialize instance variables.
	_tweet = nil;
	_twitterAPIClient = [[FDTwitterAPIClient alloc]	
		init];
	_listsRequested = NO;
	_lists = [[NSMutableArray alloc] 
		init];
	
	// Set controller's title.
	self.title = @"Tweet Details";
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView: (UITableView *)tableView 
	numberOfRowsInSection: (NSInteger)section
{
	NSInteger numberOfRows = 0;
	
	if (tableView == _tableView)
	{
		numberOfRows = [_lists count];
	}
	
	return numberOfRows;
}

- (NSString *)tableView: (UITableView *)tableView 
	titleForHeaderInSection: (NSInteger)section
{
	NSString *title = @"Lists";
	
	return title;
}

- (UITableViewCell *)tableView: (UITableView *)tableView 
	cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
	
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] 
			initWithStyle: UITableViewCellStyleSubtitle 
				reuseIdentifier: CellIdentifier];
	}
	
	if (tableView == _tableView)
	{
		FDTwitterList *twitterList = [_lists objectAtIndex: indexPath.row];
		
		cell.textLabel.text = twitterList.name;
		cell.detailTextLabel.text = twitterList.listDescription;
	}
	
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
		FDTwitterList *twitterList = [_lists objectAtIndex: indexPath.row];
		
		FDTwitterListTweetsController *twitterListTweetsController = [[FDTwitterListTweetsController alloc] 
			initWithTwitterList: twitterList];
		
		[self.navigationController pushViewController: twitterListTweetsController 
			animated: YES];
	}
}


@end