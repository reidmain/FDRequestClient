#import "FDExampleListControllerDelegate.h"


#pragma mark Class Interface

@interface FDExampleListController : UIViewController<
	UITableViewDataSource, 
	UITableViewDelegate>


#pragma mark -
#pragma mark Properties

@property (nonatomic, assign) IBOutlet id<FDExampleListControllerDelegate> delegate;


@end // @interface FDExampleListController