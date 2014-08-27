@import UIKit.UIApplication;


#pragma mark Class Interface

/**
This category adds methods on the UIApplicationClass to show and hide the networking activity indicator in the status bar.

These methods keep a counter that tracks how many times the network activity indicator has been shown/hidden. Whenever the counter moves from zero the network activity indicator is shown and whenever the counter moves back to zero it is hidden.
*/
@interface UIApplication (NetworkActivityIndicator)


#pragma mark - Static Methods

/**
Request the network activity indicator be shown.

This method is thread-safe.
*/
+ (void)showNetworkActivityIndicator;

/**
Request the network activity indicator be hidden.

This method is thread-safe.
*/
+ (void)hideNetworkActivityIndicator;


@end