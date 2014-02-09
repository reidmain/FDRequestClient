#import "FDURLRequest.h"
#import "FDURLResponse.h"


#pragma mark Constants


#pragma mark - Enumerations

#pragma mark - Type Definitions

typedef NSURLSessionAuthChallengeDisposition (^FDRequestClientTaskAuthorizationBlock)(NSURLAuthenticationChallenge *urlAuthenticationChallenge, NSURLCredential **urlCredential);
typedef void (^FDRequestClientTaskProgressBlock)(float progress);
typedef id (^FDRequestClientTaskDataParserBlock)(NSData *data);
typedef id (^FDRequestClientTaskTransformBlock)(id object);
typedef void (^FDRequestClientTaskCompletionBlock)(FDURLResponse *urlResponse);


#pragma mark - Class Interface

@interface FDRequestClientTask : NSObject


#pragma mark - Properties

@property (nonatomic, readonly) NSURLSessionTask *urlSessionTask;
@property (nonatomic, assign) BOOL callCompletionBlockOnMainThread;


#pragma mark - Constructors


#pragma mark - Static Methods


#pragma mark - Instance Methods

- (void)addCompletionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;

- (void)suspend;
- (void)resume;
- (void)cancel;


@end