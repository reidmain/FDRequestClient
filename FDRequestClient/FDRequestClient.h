#import "FDLogger.h"
#import "FDNullOrEmpty.h"
#import "FDThreadSafeMutableDictionary.h"
#import "NSDictionary+URLEncode.h"
#import "NSObject+PerformBlock.h"
#import "NSString+URLEncode.h"
#import "FDURLRequest.h"
#import "FDHTTPRequest.h"
#import "FDRequestClientTask.h"
#import "FDURLResponse.h"
#import "FDRequestClientDelegate.h"
#import "FDRequestClientCache.h"


#pragma mark Class Interface

@interface FDRequestClient : NSObject<NSURLSessionDataDelegate>


#pragma mark - Properties

@property (nonatomic, weak) id<FDRequestClientDelegate> delegate;
@property (nonatomic, weak) id<FDRequestClientCache> cache;
@property (nonatomic, copy) NSArray *headerFieldsToLog;


#pragma mark - Constructors

- (id)initWithOperationQueue: (NSOperationQueue *)operationQueue 
	urlSessionConfiguration: (NSURLSessionConfiguration *)urlSessionConfiguration;
- (id)initWithSharedOperationQueue: (BOOL)useSharedOperationQueue 
	urlSessionConfiguration: (NSURLSessionConfiguration *)urlSessionConfiguration;


#pragma mark - Instance Methods

- (FDRequestClientTask *)loadURLRequest: (NSURLRequest *)urlRequest 
	urlRequestType: (FDURLRequestType)urlRequestType 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	transformBlock: (FDRequestClientTaskTransformBlock)transformBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;

- (FDRequestClientTask *)loadURLRequest: (FDURLRequest *)urlRequest 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	transformBlock: (FDRequestClientTaskTransformBlock)transformBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;


@end