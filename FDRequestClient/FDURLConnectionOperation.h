#import "FDURLConnection.h"


#pragma mark Type Definitions

typedef void (^FDURLConnectionOperationCompletionBlock)(FDURLResponse *urlResponse);


#pragma mark -
#pragma mark Class Interface

@interface FDURLConnectionOperation : NSOperation


#pragma mark -
#pragma mark Constructors

- (id)initWithURLRequest: (NSURLRequest *)urlRequest 
	urlRequestType: (FDURLRequestType)urlRequestType 
	authorizationBlock: (FDURLConnectionAuthorizationBlock)authorizationBlock 
	progressBlock: (FDURLConnectionProgressBlock)progessBlock 
	dataParserBlock: (FDURLConnectionDataParserBlock)dataParserBlock 
	transformBlock: (FDURLConnectionTransformBlock)transformBlock 
	completionBlock: (FDURLConnectionOperationCompletionBlock)completionBlock;

- (id)initWithURLRequest: (FDURLRequest *)urlRequest 
	authorizationBlock: (FDURLConnectionAuthorizationBlock)authorizationBlock 
	progressBlock: (FDURLConnectionProgressBlock)progessBlock 
	dataParserBlock: (FDURLConnectionDataParserBlock)dataParserBlock 
	transformBlock: (FDURLConnectionTransformBlock)transformBlock 
	completionBlock: (FDURLConnectionOperationCompletionBlock)completionBlock;


#pragma mark -
#pragma mark Instance Methods

- (void)addCompletionBlock: (FDURLConnectionOperationCompletionBlock)completionBlock;


@end // @interface FDURLConnectionOperation