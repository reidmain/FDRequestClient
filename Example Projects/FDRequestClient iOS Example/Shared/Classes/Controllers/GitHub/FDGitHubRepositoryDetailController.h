#import "FDGitHubRepository.h"


#pragma mark Class Interface

@interface FDGitHubRepositoryDetailController : UIViewController<
	UITableViewDataSource, 
	UITableViewDelegate>


#pragma mark -
#pragma mark Properties

@property (nonatomic, retain) FDGitHubRepository *gitHubRepository;


#pragma mark -
#pragma mark Constructors

- (id)initWithDefaultNibName;


@end // @interface FDGitHubRepositoryDetailController