#import "FDCulture.h"


#pragma mark Class Definition

@implementation FDCulture


#pragma mark - Overridden Methods

- (NSString *)description
{
	NSString *description = [NSString stringWithFormat: @"<%@: %p; %@-%@; %@>", 
		[self class], 
		self, 
		_languageCode, 
		_countryCode, 
		_englishCultureName];
	
	return description;
}


@end