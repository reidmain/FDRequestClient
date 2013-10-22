#import "FDGitHubRepositoryDetailController.h"
#import "UIView+Layout.h"


#pragma mark Constants

static NSString * const Row_Owner = @"Owner";
static NSString * const Row_Langauge = @"Language";
static NSString * const Row_ForkCount = @"Forks";
static NSString * const Row_WatcherCount = @"Watchers";
static NSString * const Row_FollowerCount = @"Followers";
static NSString * const Row_URL = @"URL";
static NSString * const Row_CreationDate = @"Created on";
static NSString * const Row_LastPushDate = @"Last Push";
static NSString * const CellIdentifier = @"GitHubRepositoryCellIdentifier";


#pragma mark - Class Extension

@interface FDGitHubRepositoryDetailController ()

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *tableHeaderView;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;


- (void)_initializeGitHubRepositoryDetailController;


@end


#pragma mark - Class Definition

@implementation FDGitHubRepositoryDetailController
{
	@private __strong NSMutableArray *_rows;
}


#pragma mark - Constructors

- (id)initWithDefaultNibName
{
	// Abort if base initializer fails.
	if ((self = [self initWithNibName: @"FDGitHubRepositoryDetailView" 
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
	[self _initializeGitHubRepositoryDetailController];
	
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
	[self _initializeGitHubRepositoryDetailController];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Destructor

- (void)dealloc 
{
	// nil out delegates of any instance variables.
	_tableView.delegate = nil;
	_tableView.dataSource = nil;
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
	
	_descriptionLabel.text = _gitHubRepository.repoDescription;
	
	CGSize size = CGSizeMake(_descriptionLabel.width, CGFLOAT_MAX);
	NSDictionary *attributes = @{ NSFontAttributeName : _descriptionLabel.font };
	
	CGRect boundingRect = [_descriptionLabel.text boundingRectWithSize: size 
		options: NSStringDrawingUsesLineFragmentOrigin 
		attributes: attributes 
		context: nil];
	
	_tableHeaderView.height += ceilf(boundingRect.size.height) - _descriptionLabel.height;
}


#pragma mark - Private Methods

- (void)_initializeGitHubRepositoryDetailController
{
	// Initialize instance variables.
	_gitHubRepository = nil;
	_rows = [[NSMutableArray alloc] 
		initWithObjects: 
			Row_Owner, 
			Row_Langauge, 
			Row_ForkCount, 
			Row_WatcherCount, 
			Row_FollowerCount, 
			Row_URL, 
			Row_CreationDate, 
			Row_LastPushDate, 
			nil];
	
	// Set controller's title.
	self.title = @"Repo Details";
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
	UITableViewCell *cell = nil;
	
	if (tableView == _tableView)
	{
		cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
		
		if (cell == nil)
		{
			cell = [[UITableViewCell alloc] 
				initWithStyle: UITableViewCellStyleValue2 
					reuseIdentifier: CellIdentifier];
		}
		
		NSString *row = [_rows objectAtIndex: indexPath.row];
		
		if (row == Row_Owner)
		{
			cell.textLabel.text = @"Owner";
			cell.detailTextLabel.text = _gitHubRepository.owner;
		}
		else if (row == Row_Langauge)
		{
			cell.textLabel.text = @"Language";
			cell.detailTextLabel.text = _gitHubRepository.language;
		}
		else if (row == Row_ForkCount)
		{
			cell.textLabel.text = @"Forks";
			cell.detailTextLabel.text = [NSString stringWithFormat: @"%d", _gitHubRepository.forkCount];
		}
		else if (row == Row_WatcherCount)
		{
			cell.textLabel.text = @"Watchers";
			cell.detailTextLabel.text = [NSString stringWithFormat: @"%d", _gitHubRepository.watcherCount];
		}
		else if (row == Row_FollowerCount)
		{
			cell.textLabel.text = @"Followers";
			cell.detailTextLabel.text = [NSString stringWithFormat: @"%d", _gitHubRepository.followerCount];
		}
		else if (row == Row_URL)
		{
			cell.textLabel.text = @"URL";
			cell.detailTextLabel.text = [_gitHubRepository.url description];
		}
		else if (row == Row_CreationDate)
		{
			cell.textLabel.text = @"Created on";
			cell.detailTextLabel.text = [_gitHubRepository.creationDate description];
		}
		else if (row == Row_LastPushDate)
		{
			cell.textLabel.text = @"Last Push";
			cell.detailTextLabel.text = [_gitHubRepository.lastPushDate description];
		}
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
	}
}


@end