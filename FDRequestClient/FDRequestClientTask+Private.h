#import "FDRequestClientTask.h"


#pragma mark Class Interface

@interface FDRequestClientTask ()


#pragma mark - Constructors

- (id)_initWithURLSessionTask: (NSURLSessionTask *)urlSessionTask 
	urlRequestType: (FDURLRequestType)urlRequestType 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	transformBlock: (FDRequestClientTaskTransformBlock)transformBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;


#pragma mark - Instance Methods

- (NSURLSessionAuthChallengeDisposition)_dispositionForChallenge: (NSURLAuthenticationChallenge *)challenge 
	credential: (NSURLCredential **)credential;
- (void)_didReceiveResponse: (NSURLResponse *)response;
- (void)_didReceiveData: (NSData *)data;
- (void)_didCompleteWithError: (NSError *)error;


@end