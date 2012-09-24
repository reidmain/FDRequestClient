#pragma mark Class Interface

@interface FDTwitterURL : NSObject
{
}


#pragma mark -
#pragma mark Properties

@property (nonatomic, copy) NSURL *rawURL;
@property (nonatomic, copy) NSURL *displayURL;
@property (nonatomic, copy) NSURL *expandedURL;


@end // @interface FDTwitterURL