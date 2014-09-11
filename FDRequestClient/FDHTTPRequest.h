@import Foundation;


#pragma mark Constants

extern NSString * const FDHTTPRequestMethodGet;
extern NSString * const FDHTTPRequestMethodPost;
extern NSString * const FDHTTPRequestMethodDelete;
extern NSString * const FDHTTPRequestMethodPut;
typedef NSString * FDHTTPRequestMethod;


#pragma mark - Class Interface

/**
FDHTTPRequest is a simple wrapper around generating NSURLRequest objects. It encapsulates a lot of the common work that has to be done when trying to create a HTTP request using NSMutableURLRequest.
*/
@interface FDHTTPRequest : NSObject


#pragma mark - Properties

/**
The URL of the request.
*/
@property (nonatomic, copy) NSURL *url;

/**
The timeout interval of the request.
*/
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
The cache policy of the request.
*/
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;

/**
The HTTP method the request will use. The default method is FDHTTPRequestMethodGet.

FDHTTPRequestMethod is simply a typedef'd NSString to allow for the specification of "default" methods but custom methods are supported.

@see FDHTTPRequestMethod
*/
@property (nonatomic, copy) FDHTTPRequestMethod method;

/**
The HTTP header fields of the request.
*/
@property (nonatomic, strong) NSDictionary *httpHeaderFields;

/**
The query parameters that will be attached to the url when the NSURLRequest is generated.

Query parameters are automatically URL encoded.
*/
@property (nonatomic, strong) NSDictionary *parameters;

/**
The message body of the request.

Ensure you set the proper "Content-Type" header value.
*/
@property (nonatomic, strong) NSData *messageBody;


#pragma mark - Constructors

/**
Creates a request with the specfied url and the default timeout interval and cache policy.
*/
+ (instancetype)requestWithURL: (NSURL *)url;

/**
Returns an initialized request with the specfied url, timeout interval and cache policy.
 
This is the designated initializer for this class.

@param url The URL for the request.
@param timeoutInterval The timeout interval for the request, in seconds.
@param cachePolicy The cache policy for the request.
*/
- (instancetype)initWithURL: (NSURL *)url 
	timeoutInterval: (NSTimeInterval)timeoutInterval 
	cachePolicy: (NSURLRequestCachePolicy)cachePolicy;

/**
Returns an initialized request with the specfied url and the default timeout interval and cache policy.
*/
- (instancetype)initWithURL: (NSURL *)url;


#pragma mark - Instance Methods

/**
Returns a NSURLRequest object representing the HTTP request.
*/
- (NSURLRequest *)urlRequest;

/**
Sets the value for the header field. If the header was previously set it is overridden with the new value.

@param value The value for the header field.
@param field The name of the header field.
*/
- (void)setValue: (NSString *)value 
	forHTTPHeaderField: (NSString *)field;

/**
Sets the value for the query parameter.

Query parameters are automatically URL encoded.

@param value The value for the query parameter.
@param parameter The name of the query parameter to set.
*/
- (void)setValue: (id)value 
	forParameter: (NSString *)parameter;

/**
Serializes the object into JSON and sets it as the message body of the request. Also sets the "Content-Type" header to "application/json".

NSExceptions are raised if the object cannot be serialized into JSON.

@param object The object to be set as the message body.
*/
- (void)setMessageBodyWithJSONObject: (id)object;


@end