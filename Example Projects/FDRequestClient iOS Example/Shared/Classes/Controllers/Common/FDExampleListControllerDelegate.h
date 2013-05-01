#pragma mark Forward Declarations

@class FDExampleListController;


#pragma mark - Protocol

@protocol FDExampleListControllerDelegate<NSObject>


#pragma mark - Required Methods

@required

- (void)exampleListController: (FDExampleListController *)exampleListController 
	showViewController: (UIViewController *)viewController;


@end