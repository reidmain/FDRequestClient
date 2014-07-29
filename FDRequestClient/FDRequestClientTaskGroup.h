#import "FDRequestClientTask.h"


#pragma mark Type Definitions

typedef void (^FDRequestClientTaskGroupCompletionBlock)(void);


#pragma mark - Class Interface

@interface FDRequestClientTaskGroup : NSObject


#pragma mark - Properties

- (void)addRequestClientTask: (FDRequestClientTask *)requestClientTask;
- (void)addCompletionBlock: (FDRequestClientTaskGroupCompletionBlock)completionBlock;
- (void)start;


@end