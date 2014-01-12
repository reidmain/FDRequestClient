#import "FDRequestClientTask.h"


#pragma mark Class Interface

@interface FDRequestClientTask ()


#pragma mark - Constructors

- (id)initWithURLSessionTask: (NSURLSessionTask *)urlSessionTask 
	urlRequestType: (FDURLRequestType)urlRequestType 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	transformBlock: (FDRequestClientTaskTransformBlock)transformBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;


#pragma mark - Properties

//@property (nonatomic, strong) FDRequestClientTaskAuthorizationBlock authorizationBlock;
//@property (nonatomic, strong) FDRequestClientTaskProgressBlock progressBlock;
//@property (nonatomic, strong) FDRequestClientTaskDataParserBlock dataParserBlock;
//@property (nonatomic, strong) FDRequestClientTaskTransformBlock transformBlock;


#pragma mark - Instance Methods

- (NSURLSessionAuthChallengeDisposition)_dispositionForChallenge: (NSURLAuthenticationChallenge *)challenge 
	credential: (NSURLCredential **)credential;
- (void)_didReceiveResponse: (NSURLResponse *)response;
- (void)_didReceiveData: (NSData *)data;
- (void)_didCompleteWithError: (NSError *)error;


@end