#pragma mark Constants

extern NSString * const FDHTTPRequestMethodGet;
extern NSString * const FDHTTPRequestMethodPost;
extern NSString * const FDHTTPRequestMethodDelete;
extern NSString * const FDHTTPRequestMethodPut;
typedef NSString * FDHTTPRequestMethod;


#pragma mark - Class Interface

@interface FDHTTPRequest : NSObject


#pragma mark - Properties

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, copy) FDHTTPRequestMethod method;
@property (nonatomic, strong) NSDictionary *httpHeaderFields;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSData *messageBody;


#pragma mark - Constructors

- (id)initWithURL: (NSURL *)url 
	timeoutInterval: (NSTimeInterval)timeoutInterval 
	cachePolicy: (NSURLRequestCachePolicy)cachePolicy;

- (id)initWithURL: (NSURL *)url;


#pragma mark - Instance Methods

- (NSURLRequest *)urlRequest;

- (void)setValue: (NSString *)value 
	forHTTPHeaderField: (NSString *)field;

- (void)setValue: (id)value 
	forParameter: (NSString *)parameter;

- (void)setMessageBodyWithJSONObject: (id)object;

@end