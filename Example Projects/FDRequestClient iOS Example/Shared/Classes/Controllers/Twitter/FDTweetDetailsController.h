#import "FDTweet.h"


#pragma mark Class Interface

@interface FDTweetDetailsController : UIViewController<
	UITableViewDataSource, 
	UITableViewDelegate>


#pragma mark - Properties

@property (nonatomic, strong) FDTweet *tweet;


#pragma mark - Constructors

- (id)initWithDefaultNibName;


@end