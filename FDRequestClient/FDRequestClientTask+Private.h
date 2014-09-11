#import "FDRequestClientTask.h"


#pragma mark Class Interface

@interface FDRequestClientTask ()


#pragma mark - Constructors

- (instancetype)_initWithURLSessionTask: (NSURLSessionTask *)urlSessionTask 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	transformBlock: (FDRequestClientTaskTransformBlock)transformBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;


#pragma mark - Instance Methods

- (NSURLSessionAuthChallengeDisposition)_dispositionForChallenge: (NSURLAuthenticationChallenge *)challenge 
	credential: (NSURLCredential **)credential;
- (void)_didSendBodyData: (int64_t)bytesSent 
	totalBytesSent: (int64_t)totalBytesSent 
	totalBytesExpectedToSend: (int64_t)totalBytesExpectedToSend;
- (void)_didReceiveResponse: (NSURLResponse *)response;
- (void)_didReceiveData: (NSData *)data;
- (void)_didCompleteWithError: (NSError *)error;


@end