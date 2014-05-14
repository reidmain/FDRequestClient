#import "FDURLResponse.h"


#pragma mark Constants

extern NSString * const FDRequestClientTaskErrorDomain;


#pragma mark - Enumerations


#pragma mark - Type Definitions

typedef NSURLSessionAuthChallengeDisposition (^FDRequestClientTaskAuthorizationBlock)(NSURLAuthenticationChallenge *urlAuthenticationChallenge, NSURLCredential **urlCredential);
typedef void (^FDRequestClientTaskProgressBlock)(float uploadProgress, float dowloadProgress);
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

- (BOOL)addCompletionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;

- (void)suspend;
- (void)resume;
- (void)cancel;


@end