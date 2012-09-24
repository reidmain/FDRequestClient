#import "NSString+URLEncode.h"


#pragma mark Class Definition

@implementation NSString (URLEncode)


#pragma mark -
#pragma mark Public Methods

- (NSString *)urlEncode
{
	CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(
		kCFAllocatorDefault, 
		(CFStringRef)self, 
		NULL, 
		(CFStringRef)@"!*'();:@&=+$,/?%#[]",
		kCFStringEncodingUTF8);
	
	return [(NSString *)encodedString autorelease];
}


@end // @implementation NSString (URLEncode)