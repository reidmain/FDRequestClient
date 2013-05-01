#import "AppDelegate.h"
#import "FDRootViewController_iPhone.h"
#import "FDRootViewController_iPad.h"


#pragma mark Class Definition

@implementation AppDelegate
{
	@private __strong UIWindow *_mainWindow;
}


#pragma mark -
#pragma mark UIApplicationDelegate Methods

- (BOOL)application: (UIApplication *)application 
	didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
	// Create the main window.
	UIScreen *mainScreen = [UIScreen mainScreen];
	
	_mainWindow = [[UIWindow alloc] 
		initWithFrame: mainScreen.bounds];
	
	_mainWindow.backgroundColor = [UIColor blackColor];
	
	// Create the root view controller based on what platform the app is running on.
	UIDevice *currentDevice = [UIDevice currentDevice];
	
	UIUserInterfaceIdiom idiom = currentDevice.userInterfaceIdiom;
	
	UIViewController *rootViewController = nil;
	
	if (idiom == UIUserInterfaceIdiomPad)
	{
		rootViewController = [[FDRootViewController_iPad alloc] 
			init];
	}
	else
	{
		rootViewController = [[FDRootViewController_iPhone alloc] 
			init];
	}
	
	_mainWindow.rootViewController = rootViewController;
	
	// Show the main window.
    [_mainWindow makeKeyAndVisible];
	
	// Indicate success.
	return YES;
}

@end