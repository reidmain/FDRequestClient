#import "FDRootViewController_iPhone.h"
#import "FDExampleListController.h"


#pragma mark Class Definition

@implementation FDRootViewController_iPhone


#pragma mark -
#pragma mark Constructors

- (id)init
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Create a example list controller and make it the root view controller of the navigation controller.
	FDExampleListController *exampleListController = [[FDExampleListController alloc] 
		init];
	exampleListController.delegate = self;
	
	[self pushViewController: exampleListController 
		animated: NO];
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark FDExampleListControllerDelegate Methods

- (void)exampleListController: (FDExampleListController *)exampleListController 
	showViewController: (UIViewController *)viewController
{
	// Push the specified view controller onto the navigation controller.
	[self pushViewController: viewController 
		animated: YES];
}


@end // @implementation FDRootViewController_iPhone