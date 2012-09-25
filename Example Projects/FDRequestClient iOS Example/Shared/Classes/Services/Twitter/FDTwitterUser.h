#pragma mark Class Interface

@interface FDTwitterUser : NSObject<
	NSCoding>


#pragma mark -
#pragma mark Properties

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *screenName;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *bio;
@property (nonatomic, copy) NSURL *profileImageURL;
@property (nonatomic, assign) unsigned int followingCount;
@property (nonatomic, assign) unsigned int followerCount;
@property (nonatomic, assign) unsigned int listedCount;
@property (nonatomic, assign) BOOL followedByAuthenticatedUser;


@end // @interface FDTwitterUser