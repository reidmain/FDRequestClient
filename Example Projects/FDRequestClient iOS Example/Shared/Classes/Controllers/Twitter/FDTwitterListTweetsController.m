#import "FDTwitterListTweetsController.h"
#import "FDTwitterAPIClient.h"


#pragma mark Class Extension

@interface FDTwitterListTweetsController ()

- (void)_initializeTwitterListTweetsController;


@end


#pragma mark - Class Definition

@implementation FDTwitterListTweetsController
{
	@private __strong FDTwitterList *_twitterList;
	@private __strong FDTwitterAPIClient *_twitterAPIClient;
}


#pragma mark - Constructors

- (id)initWithTwitterList: (FDTwitterList *)twitterList 
	twitterAccount: (ACAccount *)twitterAccount
{
	// Abort if base initializer fails.
	if ((self = [self initWithNibName: @"FDTwitterListTweetsView" 
		bundle: nil]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_twitterList = twitterList;
	self.twitterAccount = twitterAccount;
	
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


#pragma mark - Overridden Methods

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
		account: self.twitterAccount 
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


#pragma mark - Private Methods

- (void)_initializeTwitterListTweetsController
{
	// Initialize instance variables.
	_twitterAPIClient = [[FDTwitterAPIClient alloc] 
		init];
}


@end