#import "FDGitHubRepository.h"


#pragma mark Class Interface

@interface FDGitHubRepositoryDetailController : UIViewController<
	UITableViewDataSource, 
	UITableViewDelegate>


#pragma mark - Properties

@property (nonatomic, strong) FDGitHubRepository *gitHubRepository;


#pragma mark - Constructors

- (id)initWithDefaultNibName;


@end