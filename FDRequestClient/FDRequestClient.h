#import "FDURLRequest.h"
#import "FDHTTPRequest.h"
#import "FDURLConnection.h"
#import "FDURLConnectionOperation.h"
#import "FDRequestClientDelegate.h"
#import "FDRequestClientCache.h"


#pragma mark Class Interface

@interface FDRequestClient : NSObject


#pragma mark -
#pragma mark Properties

@property (nonatomic, weak) id<FDRequestClientDelegate> delegate;
@property (nonatomic, weak) id<FDRequestClientCache> cache;


#pragma mark -
#pragma mark Constructors

- (id)initWithOperationQueue: (NSOperationQueue *)operationQueue;
- (id)initWithSharedOperationQueue: (BOOL)useSharedOperationQueue;


#pragma mark -
#pragma mark Instance Methods

- (FDURLConnectionOperation *)loadURLRequest: (NSURLRequest *)urlRequest 
	urlRequestType: (FDURLRequestType)urlRequestType 
	authorizationBlock: (FDURLConnectionAuthorizationBlock)authorizationBlock 
	progressBlock: (FDURLConnectionProgressBlock)progressBlock 
	dataParserBlock: (FDURLConnectionDataParserBlock)dataParserBlock 
	transformBlock: (FDURLConnectionTransformBlock)transformBlock 
	completionBlock: (FDURLConnectionOperationCompletionBlock)completionBlock;

- (FDURLConnectionOperation *)loadURLRequest: (FDURLRequest *)urlRequest 
	authorizationBlock: (FDURLConnectionAuthorizationBlock)authorizationBlock 
	progressBlock: (FDURLConnectionProgressBlock)progressBlock 
	dataParserBlock: (FDURLConnectionDataParserBlock)dataParserBlock 
	transformBlock: (FDURLConnectionTransformBlock)transformBlock 
	completionBlock: (FDURLConnectionOperationCompletionBlock)completionBlock;


@end // @interface FDRequestClient