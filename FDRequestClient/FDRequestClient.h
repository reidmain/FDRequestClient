#import <FDFoundationKit/FDFoundationKit.h>
#import "UIApplication+NetworkActivityIndicator.h"
#import "FDHTTPRequest.h"
#import "FDURLResponse.h"
#import "FDRequestClientTask.h"


#pragma mark Class Interface

@interface FDRequestClient : NSObject<NSURLSessionDataDelegate>


#pragma mark - Properties

@property (nonatomic, assign) BOOL logCurlCommandsToConsole;
@property (nonatomic, copy) NSArray *headerFieldsToLog;


#pragma mark - Constructors

- (id)initWithOperationQueue: (NSOperationQueue *)operationQueue 
	urlSessionConfiguration: (NSURLSessionConfiguration *)urlSessionConfiguration;
- (id)initWithSharedOperationQueue: (BOOL)useSharedOperationQueue 
	urlSessionConfiguration: (NSURLSessionConfiguration *)urlSessionConfiguration;


#pragma mark - Instance Methods

- (FDRequestClientTask *)loadURLRequest: (NSURLRequest *)urlRequest 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	transformBlock: (FDRequestClientTaskTransformBlock)transformBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;

- (FDRequestClientTask *)loadHTTPRequest: (FDHTTPRequest *)httpRequest 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	transformBlock: (FDRequestClientTaskTransformBlock)transformBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;


@end