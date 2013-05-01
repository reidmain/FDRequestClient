#import "FDGitHubAPIClient.h"


#pragma mark Class Extension

@interface FDGitHubAPIClient ()

- (NSDate *)_dateFromGitHubString: (NSString *)string;

- (FDGitHubRepository *)_gitHubRepositoryFromJSONObject: (NSDictionary *)jsonObject;

- (NSArray *)_gitHubRepositoriesFromJSONObject: (NSArray *)jsonObject;


@end


#pragma mark - Class Variables

static NSDateFormatter *_dateFormatter;


#pragma mark - Class Definition

@implementation FDGitHubAPIClient


#pragma mark - Constructors

+ (void)initialize
{
	// NOTE: initialize is called in a thead-safe manner so we don't need to worry about two shared instances possibly being created.
	
	// Create a flag to keep track of whether or not this class has been initialized because this method could be called a second time if a subclass does not override it.
	static BOOL classInitialized = NO;
	
	// If this class has not been initialized then create the shared instance.
	if (classInitialized == NO)
	{
		_dateFormatter = [[NSDateFormatter alloc] 
			init];
		[_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
		
		classInitialized = YES;
	}
}

- (id)init
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods

- (void)repositoriesForSearchQuery: (NSString *)query 
	page: (unsigned int)page 
	completion: (void (^)(FDURLResponseStatus status, NSError *error, NSArray *repositories))completion
{
	// Create resource URL for search request.
	NSString *resourceURLAsString = [NSString stringWithFormat: @"https://api.github.com/legacy/repos/search/%@", 
		[query urlEncode]];
	
	NSURL *resourceURL = [NSURL URLWithString: resourceURLAsString];
	
	// Create search request.
	FDHTTPRequest *request = [[FDHTTPRequest alloc] 
		initWithURL: resourceURL];
	request.type = FDURLRequestTypeJSON;
	request.method = FDHTTPRequestMethodGet;
	
	// Add parameters to search request.
	[request setValue: [NSString stringWithFormat: @"%d", page] 
		forParameter: @"start_page"];
	
	[request setValue: @"Testing Out Something With Spaces" 
		forParameter: @"booya"];
	
	// Load search request.
	[self loadURLRequest: request 
		authorizationBlock: nil 
		progressBlock: nil 
		dataParserBlock: nil 
		transformBlock: ^id(id jsonObject)
		{
			// Transform repositories into local entities.
			NSArray *jsonRepositories = [jsonObject objectForKey: @"repositories"];
			
			NSArray *repositories = [self _gitHubRepositoriesFromJSONObject: jsonRepositories];
			
			return repositories;
		} 
		completionBlock: ^(FDURLResponse *response)
		{
			if (response.status == FDURLResponseStatusSucceed)
			{
				completion(response.status, nil, response.content);
			}
			else
			{
				completion(response.status, response.error, nil);
			}
		}];
}


#pragma mark - Private Methods

- (NSDate *)_dateFromGitHubString: (NSString *)string
{
	NSDate *date = [_dateFormatter dateFromString: string];
	
	return date;
}

- (FDGitHubRepository *)_gitHubRepositoryFromJSONObject: (NSDictionary *)jsonObject
{
	NSString *name = [jsonObject objectForKey: @"name"];
	NSString *owner = [jsonObject objectForKey: @"owner"];
	NSString *repoDescription = [jsonObject objectForKey: @"description"];
	NSString *language = [jsonObject objectForKey: @"language"];
	NSNumber *forksNumber = [jsonObject objectForKey: @"forks"];
	NSNumber *watchersNumber = [jsonObject objectForKey: @"watchers"];
	NSNumber *folloersNumber = [jsonObject objectForKey: @"followers"];
	NSString *urlAsString = [jsonObject objectForKey: @"url"];
	NSString *creationDateAsString = [jsonObject objectForKey: @"created"];
	NSDate *creationDate = [self _dateFromGitHubString: creationDateAsString];
	NSString *lastPushDateAsString = [jsonObject objectForKey: @"pushed"];
	NSDate *lastPushDate = [self _dateFromGitHubString: lastPushDateAsString];
	
	FDGitHubRepository *repository = [[FDGitHubRepository alloc] 
		init];
	
	repository.name = name;
	repository.owner = owner;
	repository.repoDescription = repoDescription;
	repository.language = language;
	repository.forkCount = [forksNumber unsignedIntValue];
	repository.watcherCount = [watchersNumber unsignedIntValue];
	repository.followerCount = [folloersNumber unsignedIntValue];
	repository.url = [NSURL URLWithString: urlAsString];
	repository.creationDate = creationDate;
	repository.lastPushDate = lastPushDate;
	
	return repository;
}

- (NSArray *)_gitHubRepositoriesFromJSONObject: (NSArray *)jsonObject
{
	NSMutableArray *repositories = [[NSMutableArray alloc] 
		initWithCapacity: [jsonObject count]];
	
	for (NSDictionary *jsonRepository in jsonObject)
	{
		FDGitHubRepository *repository = [self _gitHubRepositoryFromJSONObject: jsonRepository];
		
		[repositories addObject: repository];
	}
	
	return repositories;
}


@end