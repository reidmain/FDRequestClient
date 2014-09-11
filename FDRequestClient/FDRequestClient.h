#import <FDFoundationKit/FDFoundationKit.h>
#import "FDHTTPRequest.h"
#import "FDURLResponse.h"
#import "FDRequestClientTask.h"
#import "FDRequestClientTaskGroup.h"
#if TARGET_OS_IPHONE
#import "UIApplication+NetworkActivityIndicator.h"
#endif


#pragma mark Class Interface

/**
FDRequestClient is a wrapper class around NSURLSession which ensapsulates all the boilerplate work that is done around managing NSURLSessionTask objects.

It handles all of the delegate methods that are associated with loading a task from a NSURLSession and wraps them in blocks that are scoped to the request that is being made.
*/
@interface FDRequestClient : NSObject<NSURLSessionDataDelegate>


#pragma mark - Properties

/**
When set to YES a curl command will be logged to the console when a request is loaded.

This allows users to easily see what requests are being made as well as duplicate those requests.
*/
@property (nonatomic, assign) BOOL logCurlCommandsToConsole;

/**
If logCurlCommandsToConsole is set to YES this value is intersected with the headers of the request being made and the resulting headers are added to the curl command logged to the console.

By default the "Authorization" field is the only field that is logged.
*/
@property (nonatomic, copy) NSArray *headerFieldsToLog;


#pragma mark - Constructors

/**
Returns an initialized request client with the specfied operation queue and session configuration.
 
This is the designated initializer for this class.

@param operationQueue The operation queue that all callback blocks will be executed on.
@param urlSessionConfiguration The configuration object that the backing NSURLSession will use.
*/
- (instancetype)initWithOperationQueue: (NSOperationQueue *)operationQueue 
	urlSessionConfiguration: (NSURLSessionConfiguration *)urlSessionConfiguration;

/**
Returns an initialized request client with either a shared or unique operation queue and the specified session configuration.

@param useSharedOperationQueue If YES a library-provided operation queue will be used otherwise a operation queue will be created specifically for this instance of the request client.
@param urlSessionConfiguration The configuration object that the backing NSURLSession will use.
*/
- (instancetype)initWithSharedOperationQueue: (BOOL)useSharedOperationQueue 
	urlSessionConfiguration: (NSURLSessionConfiguration *)urlSessionConfiguration;


#pragma mark - Instance Methods

/**
Starts loading a URL request asynchronously and executes a number of blocks while the request is being loaded.

@param urlRequest The URL request to load.
@param authorizationBlock The block to call when an authentication challenge occurs. This parameter may be nil.
@param progressBlock The block to call when the progress of the request is updated. This parameter may be nil.
@param dataParserBlock The block to call when parsing the NSData returned from the request. If this parameter is nil the NSData is automatically parsed based on the 'Content-Type' header of the response. This parameter may be nil.
@param transformBlock The block to call to transform the object returned from the dataParserBlock into the object that will be passed to the completionBlock. This parameter may be nil.
@param completionBlock The block to call when the request finishes loading and the response has been generated. This parameter may be nil.

@return A client task for the request being loaded.
*/
- (FDRequestClientTask *)loadURLRequest: (NSURLRequest *)urlRequest 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	transformBlock: (FDRequestClientTaskTransformBlock)transformBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;

/**
Starts loading a HTTP request asynchronously and executes a number of blocks while the request is being loaded.

This method takes the HTTP request, converts in into a URL request and calls loadURLRequest:authorizationBlock:progressBlock:dataParserBlock:transformBlock:completionBlock:.

@param httpRequest The HTTP request to load.
@param authorizationBlock The block to call when an authentication challenge occurs. This parameter may be nil.
@param progressBlock The block to call when the progress of the request is updated. This parameter may be nil.
@param dataParserBlock The block to call when parsing the NSData returned from the request. If this parameter is nil the NSData is automatically parsed based on the 'Content-Type' header of the response. This parameter may be nil.
@param transformBlock The block to call to transform the object returned from the dataParserBlock into the object that will be passed to the completionBlock. This parameter may be nil.
@param completionBlock The block to call when the request finishes loading and the response has been generated. This parameter may be nil.

@return A client task for the request being loaded.

@see [FDRequestClient loadURLRequest:authorizationBlock:progressBlock:dataParserBlock:transformBlock:completionBlock:]
*/
- (FDRequestClientTask *)loadHTTPRequest: (FDHTTPRequest *)httpRequest 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	transformBlock: (FDRequestClientTaskTransformBlock)transformBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;


@end