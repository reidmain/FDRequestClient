#import "FDSplitViewController.h"


#pragma mark Class Definition

@implementation FDSplitViewController


#pragma mark - Properties

- (UIViewController *)masterViewController
{
	UIViewController *masterViewController = [self.viewControllers fd_tryObjectAtIndex: 0];
	
	return masterViewController;
}
- (void)setMasterViewController: (UIViewController *)masterViewController
{
	self.viewControllers = [NSArray arrayWithObjects: 
		masterViewController, 
		self.detailViewController, 
		nil];
}

- (UIViewController *)detailViewController
{
	UIViewController *detailViewController = [self.viewControllers fd_tryObjectAtIndex: 1];
	
	return detailViewController;
}
- (void)setDetailViewController: (UIViewController *)detailViewController
{
	self.viewControllers = [NSArray arrayWithObjects: 
		self.masterViewController, 
		detailViewController, 
		nil];
}


@end