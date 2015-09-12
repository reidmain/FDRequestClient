#import "FDRequestClientTaskGroup.h"

@import FDFoundationKit;


#pragma mark - Class Definition

@implementation FDRequestClientTaskGroup
{
	@private __strong dispatch_group_t _dispatchGroup;
	@private __strong NSMutableArray *_requestClientTasks;
	@private __strong NSMutableArray *_completionBlocks;
}


#pragma mark - Initializers

- (instancetype)init
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_dispatchGroup = dispatch_group_create();
	_requestClientTasks = [NSMutableArray array];
	_completionBlocks = [NSMutableArray array];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods

- (void)addRequestClientTask: (FDRequestClientTask *)requestClientTask
{
	// Ensure the task is suspended and track it so it can be restarted again when the group is started.
	[requestClientTask suspend];
	
	[_requestClientTasks addObject: requestClientTask];
	
	// Have the task join the dispatch group.
	dispatch_group_enter(_dispatchGroup);
	[requestClientTask addCompletionBlock: ^(FDURLResponse *urlResponse)
		{
			dispatch_group_leave(_dispatchGroup);
		}];
}

- (void)addCompletionBlock: (FDRequestClientTaskGroupCompletionBlock)completionBlock
{
	// If the completion block is nil there is nothing to add.
	if (FDIsEmpty(completionBlock) == YES)
	{
		return;
	}
	
	// Track the completion block so it can be added as a notification block when the group is started.
	[_completionBlocks addObject: completionBlock];
}

- (void)start
{
	// Add all completion blocks to the dispatch group as notification blocks.
	for (FDRequestClientTaskGroupCompletionBlock completionBlock in _completionBlocks)
	{
		dispatch_group_notify(_dispatchGroup, dispatch_get_main_queue(), completionBlock);
	}
	
	// Ensure all the tasks are running.
	for (FDRequestClientTask *requestClientTask in _requestClientTasks)
	{
		[requestClientTask resume];
	}
	
	// Release all the tasks and completion blocks to prevent possible retain loops with the task group.
	_requestClientTasks = [NSMutableArray array];
	_completionBlocks = [NSMutableArray array];
}


@end