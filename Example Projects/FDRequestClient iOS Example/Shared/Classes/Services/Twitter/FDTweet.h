#import "FDTwitterUser.h"
#import "FDTwitterURL.h"


#pragma mark Class Interface

@interface FDTweet : NSObject


#pragma mark -
#pragma mark Properties

@property (nonatomic, copy) NSString *tweetId;
@property (nonatomic, strong) FDTwitterUser *user;
@property (nonatomic, copy) NSDate *creationDate;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, readonly) NSMutableArray *urls;
@property (nonatomic, assign) BOOL favourited;
@property (nonatomic, assign) BOOL retweeted;
@property (nonatomic, assign) unsigned int retweetCount;


@end // @interface FDTweet