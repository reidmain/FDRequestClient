#import "FDTweetListController.h"
#import "FDTweet.h"
#import "FDTweetDetailsController.h"
#import "FDNullOrEmpty.h"
#import "UIImageView+WebImage.h"
#import "UIView+Layout.h"


#pragma mark Constants

static NSString * const CellIdentifier = @"TweetListCellIdentifier";


#pragma mark -
#pragma mark Class Extension

@interface FDTweetListController ()

@property (nonatomic, strong, readwrite) IBOutlet FDInfiniteTableView *infiniteTableView;


- (void)_initializeTweetListController;


@end // @interface FDTweetListController ()


#pragma mark -
#pragma mark Class Definition

@implementation FDTweetListController
{
	@private __strong NSMutableArray *_tweets;
}

#pragma mark -
#pragma mark Constructors

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
	[self _initializeTweetListController];
	
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
	[self _initializeTweetListController];
	
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
}


#pragma mark -
#pragma mark Public Methods

- (void)addTweets: (NSArray *)tweets 
	withRowAnimation: (UITableViewRowAnimation)rowAnimation
{
	if (rowAnimation == UITableViewRowAnimationNone)
	{
		[_tweets addObjectsFromArray: tweets];
		[_infiniteTableView reloadData];
	}
	else
	{
		NSMutableArray *rowsToInsert = [[NSMutableArray alloc] 
			initWithCapacity: [tweets count]];
		
		NSUInteger startingIndex = 0;
		if (FDIsEmpty(_tweets) == NO)
		{
			startingIndex = [_tweets count];
		}
		
		for (NSUInteger i=startingIndex; i < [_tweets count] + [tweets count]; i++)
		{
			NSIndexPath *indexPathToInsert = [NSIndexPath indexPathForRow: i inSection: 0];
			
			[rowsToInsert addObject: indexPathToInsert];
		}
		
		[_tweets addObjectsFromArray: tweets];
		
		[_infiniteTableView insertRowsAtIndexPaths: rowsToInsert 
			withRowAnimation: rowAnimation];
	}
}

- (void)clearTweetsWithRowAnimation: (UITableViewRowAnimation)rowAnimation
{
	if (rowAnimation == UITableViewRowAnimationNone)
	{
		[_tweets removeAllObjects];
		[_infiniteTableView reloadData];
	}
	else
	{
		NSMutableArray *rowsToDelete = [[NSMutableArray alloc] 
			initWithCapacity: [_tweets count]];
		
		for (NSUInteger i=0; i < [_tweets count]; i++)
		{
			NSIndexPath *indexPathToDelete = [NSIndexPath indexPathForRow: i inSection: 0];
			
			[rowsToDelete addObject: indexPathToDelete];
		}
		
		[_tweets removeAllObjects];
		
		[_infiniteTableView deleteRowsAtIndexPaths: rowsToDelete 
			withRowAnimation: rowAnimation];
	}
}

- (void)loadTweets
{
	[_infiniteTableView showLoadingView];
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
	
	_infiniteTableView.rowHeight = 80.0f;
}


#pragma mark -
#pragma mark Private Methods

- (void)_initializeTweetListController
{
	// Initialize instance variables.
	_tweets = [[NSMutableArray alloc] 
		init];
}


#pragma mark -
#pragma mark FDInfiniteTableViewDataSource Methods

- (BOOL)canLoadDataForInfiniteTableView: (FDInfiniteTableView *)infiniteTableView
{
	BOOL canLoadData = NO;
	
	if (infiniteTableView == _infiniteTableView)
	{
		if ([_tweets count] > 0)
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
		[self loadTweets];
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
		numberOfRows = [_tweets count];
	}
	
	return numberOfRows;
}

- (UITableViewCell *)tableView: (UITableView *)tableView 
	cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	
	if (tableView == _infiniteTableView)
	{
		cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
		
		if (cell == nil)
		{
			cell = [[UITableViewCell alloc] 
				initWithStyle: UITableViewCellStyleSubtitle 
					reuseIdentifier: CellIdentifier];
			
			cell.detailTextLabel.numberOfLines = 3;
			
			cell.imageView.layer.cornerRadius = 4.0f;
			cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
			cell.imageView.clipsToBounds = YES;
		}
	
		FDTweet *tweet = [_tweets objectAtIndex: indexPath.row];
		
		cell.textLabel.text = tweet.user.name;
		cell.detailTextLabel.text = tweet.text;
		
		[cell.imageView loadImageFromURL: tweet.user.profileImageURL 
			placeholderImage: [UIImage imageNamed:@"twitter_logo.png"]];
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
	
	if (tableView == _infiniteTableView)
	{
		FDTweet *tweet = [_tweets objectAtIndex: indexPath.row];
		
		FDTweetDetailsController *tweetDetailsController = [[FDTweetDetailsController alloc] 
			initWithDefaultNibName];
		tweetDetailsController.tweet = tweet;
		
		[self.navigationController pushViewController: tweetDetailsController 
			animated: YES];
	}
}


@end // @implementation FDTweetListController