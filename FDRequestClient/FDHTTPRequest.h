#import "FDURLRequest.h"


#pragma mark Constants

extern NSString * const FDHTTPRequestMethodGet;
extern NSString * const FDHTTPRequestMethodPost;
extern NSString * const FDHTTPRequestMethodDelete;
extern NSString * const FDHTTPRequestMethodPut;
typedef NSString * FDHTTPRequestMethod;


#pragma mark - Class Interface

@interface FDHTTPRequest : FDURLRequest


#pragma mark - Properties

@property (nonatomic, copy) FDHTTPRequestMethod method;
@property (nonatomic, strong) NSDictionary *httpHeaderFields;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSData *messageBody;


#pragma mark - Instance Methods

- (void)setValue: (NSString *)value 
	forHTTPHeaderField: (NSString *)field;

- (void)setValue: (NSString *)value 
	forParameter: (NSString *)parameter;


@end