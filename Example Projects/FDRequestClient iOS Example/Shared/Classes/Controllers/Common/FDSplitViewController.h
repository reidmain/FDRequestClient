#pragma mark Class Interface

@interface FDSplitViewController : UISplitViewController


#pragma mark -
#pragma mark Properties

@property (nonatomic, retain) IBOutlet UIViewController *masterViewController;
@property (nonatomic, retain) IBOutlet UIViewController *detailViewController;


@end // @interface FDSplitViewController