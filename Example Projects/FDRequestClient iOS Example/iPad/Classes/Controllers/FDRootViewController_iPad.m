#import "FDRootViewController_iPad.h"
#import "FDSearchTweetsController.h"


#pragma mark Class Definition

@implementation FDRootViewController_iPad


#pragma mark -
#pragma mark Constructors

- (id)init
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Create a example list controller and make it the master controller of the split view controller.
	FDExampleListController *exampleListController = [[FDExampleListController alloc] 
		init];
	exampleListController.delegate = self;
	
	UINavigationController *masterController = [[UINavigationController alloc] 
		initWithRootViewController: exampleListController];
	
	[exampleListController release];
	
	self.masterViewController = masterController;
	
	[masterController release];
	
	// Create a search tweets controller and make it the detail controller of the split view controller.
	FDSearchTweetsController *searchTweetsController = [[FDSearchTweetsController alloc] 
		initWithDefaultNibName];
	
	UINavigationController *detailController = [[UINavigationController alloc] 
		initWithRootViewController: searchTweetsController];
	
	[searchTweetsController release];
	
	self.detailViewController = detailController;
	
	[detailController release];
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark FDExampleListControllerDelegate Methods

- (void)exampleListController: (FDExampleListController *)exampleListController 
	showViewController: (UIViewController *)viewController
{
	// Show the specified view controller in the detail view of the split view controller.
	UINavigationController *detailController = [[UINavigationController alloc] 
		initWithRootViewController: viewController];
	
	self.detailViewController = detailController;
	
	[detailController release];
}


@end // @implementation FDRootViewController_iPad