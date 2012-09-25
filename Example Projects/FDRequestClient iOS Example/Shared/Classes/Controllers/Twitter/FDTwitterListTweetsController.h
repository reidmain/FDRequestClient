#import "FDTweetListController.h"
#import "FDTwitterList.h"


#pragma mark Class Interface

@interface FDTwitterListTweetsController : FDTweetListController


#pragma mark -
#pragma mark Properties

@property (nonatomic, strong) FDTwitterList *twitterList;


#pragma mark -
#pragma mark Constructors

- (id)initWithTwitterList: (FDTwitterList *)twitterList;


@end // @interface FDTwitterListTweetsController