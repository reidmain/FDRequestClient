#import "AppDelegate.h"
#import "FDCulture.h"


#pragma mark Class Definition

@implementation AppDelegate


#pragma mark - NSApplicationDelegate Methods

- (void)applicationDidFinishLaunching: (NSNotification *)notification
{
	FDRequestClient *requestClient = [FDRequestClient new];
	
	NSURL *url = [NSURL URLWithString: @"http://api.feedzilla.com/v1/cultures.json"];
	
	FDHTTPRequest *httpRequest = [[FDHTTPRequest alloc] 
		initWithURL: url];
	
	[requestClient loadHTTPRequest: httpRequest 
		authorizationBlock: nil 
		progressBlock: ^(float uploadProgress, float dowloadProgress)
			{
				NSLog(@"Progress: %.1f%%", dowloadProgress * 100);
			} 
		dataParserBlock: nil 
		transformBlock: ^id(id object)
			{
				id transformedObject = object;
				
				if ([object isKindOfClass: [NSArray class]] == YES)
				{
					transformedObject = [NSMutableArray array];
					
					[object enumerateObjectsUsingBlock: ^(NSDictionary *dictionary, NSUInteger idx, BOOL *stop)
						{
							FDCulture *culture = [FDCulture new];
							
							culture.languageCode = [dictionary objectForKey: @"language_code"];
							culture.countryCode = [dictionary objectForKey: @"country_code"];
							culture.cultureCode = [dictionary objectForKey: @"culture_code"];
							culture.displayCultureName = [dictionary objectForKey: @"display_culture_name"];
							culture.englishCultureName = [dictionary objectForKey: @"english_culture_name"];
							
							[transformedObject addObject: culture];
						}];
				}
				return transformedObject;
			} 
		completionBlock: ^(FDURLResponse *urlResponse)
			{
				NSLog(@"Finished loading:\n%@", urlResponse.content);
			}];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed: (NSApplication *)sender
{
	return YES;
}


@end