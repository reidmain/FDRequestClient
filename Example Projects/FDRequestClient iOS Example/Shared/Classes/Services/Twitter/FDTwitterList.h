#import "FDTwitterUser.h"


#pragma mark Class Interface

@interface FDTwitterList : NSObject


#pragma mark -
#pragma mark Properties

@property (nonatomic, copy) NSString *listId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *listDescription;
@property (nonatomic, assign) unsigned int memberCount;
@property (nonatomic, assign) unsigned int subscriberCount;
@property (nonatomic, retain) FDTwitterUser *creator;


@end // @interface FDTwitterList