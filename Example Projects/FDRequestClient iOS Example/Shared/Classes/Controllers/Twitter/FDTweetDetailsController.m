#import "FDTweetDetailsController.h"
#import "FDTwitterAPIClient.h"
#import "FDTwitterListTweetsController.h"
#import "FDNullOrEmpty.h"
#import "UIImageView+WebImage.h"
#import "UIView+Layout.h"


#pragma mark Constants

static NSString * const CellIdentifier = @"TweetDetailsCellIdentifier";


#pragma mark -
#pragma mark Class Extension

@interface FDTweetDetailsController ()

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIView *tableHeaderView;
@property (nonatomic, retain) IBOutlet UIImageView *profileImageView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *screenNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UIView *tableFooterView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) IBOutlet UILabel *noListsLabel;

- (void)_initializeTweetDetailsController;


@end // @interface FDTweetDetailsController ()


#pragma mark -
#pragma mark Class Definition

@implementation FDTweetDetailsController
{
	@private UITableView *_tableView;
	@private UIView *_tableHeaderView;
	@private UIImageView *_profileImageView;
	@private UILabel *_nameLabel;
	@private UILabel *_screenNameLabel;
	@private UILabel *_textLabel;
	@private UIView *_tableFooterView;
	@private UIActivityIndicatorView *_activityIndicatorView;
	@private UILabel *_noListsLabel;
	
	@private FDTweet *_tweet;
	@private FDTwitterAPIClient *_twitterAPIClient;
	@private BOOL _listsRequested;
	@private NSMutableArray *_lists;
}


#pragma mark -
#pragma mark Properties

@synthesize tableView = _tableView;
@synthesize tableHeaderView = _tableHeaderView;
@synthesize profileImageView = _profileImageView;
@synthesize nameLabel = _nameLabel;
@synthesize screenNameLabel = _screenNameLabel;
@synthesize textLabel = _textLabel;
@synthesize tableFooterView = _tableFooterView;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize noListsLabel = _noListsLabel;

@synthesize tweet = _tweet;


#pragma mark -
#pragma mark Constructors

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
    bundle:(NSBundle *)bundle
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


#pragma mark -
#pragma mark Destructor

- (void)dealloc 
{
	// nil out delegates of any instance variables.
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
	
	// Release instance variables.
	[_tableView release];
	[_tableHeaderView release];
	[_profileImageView release];
	[_nameLabel release];
	[_screenNameLabel release];
	[_textLabel release];
	[_tableFooterView release];
	[_activityIndicatorView release];
	[_noListsLabel release];
	
	[_tweet release];
	[_twitterAPIClient release];
	[_lists release];
	
	// Call the base destructor.
	[super dealloc];
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


#pragma mark -
#pragma mark Private Methods

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


#pragma mark -
#pragma mark UITableViewDataSource Methods

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
		cell = [[[UITableViewCell alloc] 
			initWithStyle: UITableViewCellStyleSubtitle 
				reuseIdentifier: CellIdentifier] 
					autorelease];
	}
	
	if (tableView == _tableView)
	{
		FDTwitterList *twitterList = [_lists objectAtIndex: indexPath.row];
		
		cell.textLabel.text = twitterList.name;
		cell.detailTextLabel.text = twitterList.listDescription;
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
	
	if (tableView == _tableView)
	{
		FDTwitterList *twitterList = [_lists objectAtIndex: indexPath.row];
		
		FDTwitterListTweetsController *twitterListTweetsController = [[FDTwitterListTweetsController alloc] 
			initWithTwitterList: twitterList];
		
		[self.navigationController pushViewController: twitterListTweetsController 
			animated: YES];
		
		[twitterListTweetsController release];
	}
}


@end // @implementation FDTweetDetailsController