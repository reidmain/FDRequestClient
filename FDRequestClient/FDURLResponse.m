#import "FDURLResponse.h"
#import "FDURLResponse+Private.h"


#pragma mark Class Definition

@implementation FDURLResponse


#pragma mark - Constructors

- (instancetype)initWithStatus: (FDURLResponseStatus)status 
	content: (id)content 
	error: (NSError *)error 
	rawURLResponse: (NSURLResponse *)rawURLResponse
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}

	
	// Initialize instance variables.
	_status = status;
	_content = content;
	_error = error;
	_rawURLResponse = rawURLResponse;
	
	// Return initialized instance.
	return self;
}


#pragma mark - Overridden Methods

- (NSString *)debugDescription
{
	NSString *statusString = nil;
	switch (_status)
	{
		case FDURLResponseStatusSucceed:
		{
			statusString = @"Succeed";
			
			break;
		}
		
		case FDURLResponseStatusFailed:
		{
			statusString = @"Failed";
			
			break;
		}
		
		case FDURLResponseStatusCancelled:
		{
			statusString = @"Cancelled";
			
			break;
		}
	}
	
	NSString *description = [NSString stringWithFormat: @"<%@: %p; status = %@; URL = %@; content = %@;>", 
		[self class], 
		self, 
		statusString, 
		[_rawURLResponse URL], 
		_content];
	
	return description;
}


@end