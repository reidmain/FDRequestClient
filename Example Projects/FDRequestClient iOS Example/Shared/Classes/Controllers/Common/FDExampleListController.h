#import "FDExampleListControllerDelegate.h"


#pragma mark Class Interface

@interface FDExampleListController : UIViewController<
	UITableViewDataSource, 
	UITableViewDelegate>


#pragma mark - Properties

@property (nonatomic, weak) IBOutlet id<FDExampleListControllerDelegate> delegate;


@end