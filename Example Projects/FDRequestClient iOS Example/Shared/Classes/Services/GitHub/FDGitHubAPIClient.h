#import "FDRequestClient.h"
#import "FDGitHubRepository.h"


#pragma mark Class Interface

@interface FDGitHubAPIClient : FDRequestClient


#pragma mark -
#pragma mark Instance Methods

- (void)repositoriesForSearchQuery: (NSString *)query 
	page: (unsigned int)page 
	completion: (void (^)(FDURLResponseStatus status, NSError *error, NSArray *repositories))completion;


@end // @interface FDGitHubAPIClient