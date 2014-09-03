#import <Foundation/Foundation.h>


#pragma mark Class Interface

@interface FDCulture : NSObject


#pragma mark - Properties

@property (nonatomic, copy) NSString *languageCode;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *cultureCode;
@property (nonatomic, copy) NSString *displayCultureName;
@property (nonatomic, copy) NSString *englishCultureName;


@end