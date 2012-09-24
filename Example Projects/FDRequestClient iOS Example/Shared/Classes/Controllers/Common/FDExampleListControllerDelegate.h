#pragma mark Forward Declarations

@class FDExampleListController;


#pragma mark -
#pragma mark Protocol

@protocol FDExampleListControllerDelegate<NSObject>


#pragma mark -
#pragma mark Required Methods

@required

- (void)exampleListController: (FDExampleListController *)exampleListController 
	showViewController: (UIViewController *)viewController;


@end // @protocol FDExampleListControllerDelegate