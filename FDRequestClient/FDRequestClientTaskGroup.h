#import "FDRequestClientTask.h"


#pragma mark Type Definitions

/**
This block is called when the all the tasks in the group have finished loading.
*/
typedef void (^FDRequestClientTaskGroupCompletionBlock)(void);


#pragma mark - Class Interface

/**
FDRequestClientTaskGroup allows you to group a bunch of request client tasks together and be notified when all the tasks have finished loading.
*/
@interface FDRequestClientTaskGroup : NSObject


#pragma mark - Properties

/**
Adds the specified task to the group.

The task is immediately suspended to ensure no tasks are running until the group is started.

@param requestClientTask The task to add to the group.
*/
- (void)addRequestClientTask: (FDRequestClientTask *)requestClientTask;

/**
Adds the completion block to the list of blocks to be called when all the tasks in the group have finished loading.

@param completionBlock The completion block to add.
*/
- (void)addCompletionBlock: (FDRequestClientTaskGroupCompletionBlock)completionBlock;

/**
Resumes all the tasks in the group.
*/
- (void)start;


@end