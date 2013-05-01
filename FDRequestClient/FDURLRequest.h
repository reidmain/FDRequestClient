#pragma mark Constants

extern NSString * const FDURLRequestTypeRaw;
extern NSString * const FDURLRequestTypeString;
extern NSString * const FDURLRequestTypeImage;
extern NSString * const FDURLRequestTypeJSON;
typedef NSString * FDURLRequestType;


#pragma mark - Class Interface

@interface FDURLRequest : NSObject


#pragma mark - Properties

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSTimeInterval timeoutInterval;
@property (nonatomic, readonly) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, copy) FDURLRequestType type;


#pragma mark - Constructors

- (id)initWithURL: (NSURL *)url 
	timeoutInterval: (NSTimeInterval)timeoutInterval 
	cachePolicy: (NSURLRequestCachePolicy)cachePolicy;

- (id)initWithURL: (NSURL *)url;

- (id)initWithURLRequest: (NSURLRequest *)urlRequest;


#pragma mark - Public Methods

- (NSURLRequest *)rawURLRequest;


@end