#import "FDTwitterListTweetsController.h"
#import "FDTwitterAPIClient.h"


#pragma mark Class Extension

@interface FDTwitterListTweetsController ()

- (void)_initializeTwitterListTweetsController;


@end // @interface FDTwitterListTweetsController ()


#pragma mark -
#pragma mark Class Definition

@implementation FDTwitterListTweetsController
{
	@private FDTwitterList *_twitterList;
	@private FDTwitterAPIClient *_twitterAPIClient;
}


#pragma mark -
#pragma mark Properties

@synthesize twitterList = _twitterList;
- (void)setTwitterList: (FDTwitterList *)twitterList
{
	if (_twitterList != twitterList)
	{
		_twitterList = twitterList;
		
		// Set controller's title.
		self.title = _twitterList.name;
	}
}


#pragma mark -
#pragma mark Constructors

- (id)initWithTwitterList: (FDTwitterList *)twitterList
{
	// Abort if base initializer fails.
	if ((self = [self initWithNibName: @"FDTwitterListTweetsView" 
		bundle: nil]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_twitterList = [twitterList retain];
	
	// Set controller's title.
	self.title = _twitterList.name;

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
	[self _initializeTwitterListTweetsController];
	
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
	[self _initializeTwitterListTweetsController];
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc 
{
	// Release instance variables.
	[_twitterList release];
	[_twitterAPIClient release];
	
	// Call the base destructor.
	[super dealloc];
}


#pragma mark -
#pragma mark Overridden Methods

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidAppear: (BOOL)animated
{
	[super viewDidAppear: animated];
	
	[self loadTweets];
}

- (void)loadTweets
{
	[super loadTweets];
	
	FDTweet *oldestTweet = [self.tweets lastObject];
	
	[_twitterAPIClient tweetsForListId: _twitterList.listId 
		maxTweetId: oldestTweet.tweetId 
		account: nil 
		completion: ^(FDURLResponseStatus status, NSError *error, NSArray *tweets)
		{
			[self.infiniteTableView doneLoading];
			
			if (status == FDURLResponseStatusSucceed)
			{
				[self addTweets: tweets 
					withRowAnimation: UITableViewRowAnimationAutomatic];
			}
		}];
}


#pragma mark -
#pragma mark Private Methods

- (void)_initializeTwitterListTweetsController
{
	// Initialize instance variables.
	_twitterAPIClient = [[FDTwitterAPIClient alloc] 
		init];
}


@end // @implementation FDTwitterListTweetsController