#pragma mark Class Interface

@interface FDGitHubRepository : NSObject


#pragma mark - Properties

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *owner;
@property (nonatomic, copy) NSString *repoDescription;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, assign) unsigned int forkCount;
@property (nonatomic, assign) unsigned int watcherCount;
@property (nonatomic, assign) unsigned int followerCount;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSDate *creationDate;
@property (nonatomic, copy) NSDate *lastPushDate;


@end