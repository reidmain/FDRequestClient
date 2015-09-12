#import "UIApplication+NetworkActivityIndicator.h"

@import FDFoundationKit;


#pragma mark - Constants

static NSInteger _ActivityCounter = 0;


#pragma mark - Class Definition

@implementation UIApplication (NetworkActivityIndicator)


#pragma mark - Public Methods

+ (void)fd_showNetworkActivityIndicator
{
	UIApplication *sharedApplication = [UIApplication sharedApplication];
	@synchronized(sharedApplication)
	{
		// If the activity counter is zero start the network activity indicator before incrementing the counter.
		if (_ActivityCounter == 0)
		{
			[sharedApplication fd_performBlockOnMainThread: ^
				{
					sharedApplication.networkActivityIndicatorVisible = YES;
				}];
		}
		
		_ActivityCounter++;
	}
}

+ (void)fd_hideNetworkActivityIndicator
{
	UIApplication *sharedApplication = [UIApplication sharedApplication];
	@synchronized(sharedApplication)
	{
		// Decrement the activity counter and if it is less than zero stop showing the activity indicator.
		_ActivityCounter--;
		
		if (_ActivityCounter <= 0)
		{
			[sharedApplication fd_performBlockOnMainThread: ^
				{
					sharedApplication.networkActivityIndicatorVisible = NO;
				}];
		}
	}
}


@end