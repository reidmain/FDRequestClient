#pragma mark Class Interface

@interface FDSplitViewController : UISplitViewController


#pragma mark -
#pragma mark Properties

@property (nonatomic, strong) IBOutlet UIViewController *masterViewController;
@property (nonatomic, strong) IBOutlet UIViewController *detailViewController;


@end // @interface FDSplitViewController