#import "FDURLRequest.h"


#pragma mark Type Definitions

typedef NSData *(^FDHTTPRequestMessageBodyProvider)(void);


#pragma mark -
#pragma mark Constants

extern NSString * const FDHTTPRequestMethodGet;
extern NSString * const FDHTTPRequestMethodPost;
extern NSString * const FDHTTPRequestMethodDelete;
extern NSString * const FDHTTPRequestMethodPut;
typedef NSString * FDHTTPRequestMethod;


#pragma mark -
#pragma mark Class Interface

@interface FDHTTPRequest : FDURLRequest


#pragma mark -
#pragma mark Properties

@property (nonatomic, copy) FDHTTPRequestMethod method;
@property (nonatomic, strong) NSDictionary *httpHeaderFields;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSData *messageBody;
@property (nonatomic, copy) FDHTTPRequestMessageBodyProvider messageBodyProvider;


#pragma mark -
#pragma mark Instance Methods

- (void)setValue: (NSString *)value 
	forHTTPHeaderField: (NSString *)field;

- (void)setValue: (NSString *)value 
	forParameter: (NSString *)parameter;


@end // @interface FDHTTPRequest