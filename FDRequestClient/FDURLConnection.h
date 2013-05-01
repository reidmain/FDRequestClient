#import "FDURLRequest.h"
#import "FDURLResponse.h"


#pragma mark Type Definitions

typedef void (^FDURLConnectionAuthorizationBlock)(NSURLAuthenticationChallenge *urlAuthenticationChallenge);
typedef void (^FDURLConnectionProgressBlock)(float progress);
typedef id (^FDURLConnectionDataParserBlock)(NSData *data);
typedef id (^FDURLConnectionTransformBlock)(id object);


#pragma mark - Class Interface

@interface FDURLConnection : NSObject<
	NSURLConnectionDataDelegate>


#pragma mark - Constructors

- (id)initWithURLRequest: (NSURLRequest *)urlRequest 
	urlRequestType: (FDURLRequestType)urlRequestType;

- (id)initWithURLRequest: (FDURLRequest *)urlRequest;


#pragma mark - Instance Methods

- (FDURLResponse *)loadWithAuthorizationBlock: (FDURLConnectionAuthorizationBlock)authorizationBlock 
	progressBlock: (FDURLConnectionProgressBlock)progessBlock 
	dataParserBlock: (FDURLConnectionDataParserBlock)dataParserBlock 
	transformBlock: (FDURLConnectionTransformBlock)transformBlock;

- (FDURLResponse *)loadWithDataParserBlock: (FDURLConnectionDataParserBlock)dataParserBlock
	transformBlock: (FDURLConnectionTransformBlock)transformBlock;

- (FDURLResponse *)loadWithTransformBlock: (FDURLConnectionTransformBlock)transformBlock;

- (FDURLResponse *)load;

- (void)cancel;


@end