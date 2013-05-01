#pragma mark Class Interface

@interface FDSplitViewController : UISplitViewController


#pragma mark - Properties

@property (nonatomic, strong) IBOutlet UIViewController *masterViewController;
@property (nonatomic, strong) IBOutlet UIViewController *detailViewController;


@end