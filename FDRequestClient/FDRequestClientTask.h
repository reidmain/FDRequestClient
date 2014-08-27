#import "FDURLResponse.h"


#pragma mark Constants

extern NSString * const FDRequestClientTaskErrorDomain;


#pragma mark - Type Definitions

/**
This block is called if the task encounters an authorization challenge.

@param urlAuthenticationChallenge An object that contains the request for authentication.
@param urlCredential The credential that should be used for authentication.

@return Returns a NSURLSessionAuthChallengeDisposition constant that describes how the challenge should be handled.
*/
typedef NSURLSessionAuthChallengeDisposition (^FDRequestClientTaskAuthorizationBlock)(NSURLAuthenticationChallenge *urlAuthenticationChallenge, NSURLCredential **urlCredential);

/**
This block is called to indicate the upload and download progress of the task.

@param uploadProgress The upload progress of the task between 0.0 and 1.0.
@param dowloadProgress The download progress of the task between 0.0 and 1.0.
*/
typedef void (^FDRequestClientTaskProgressBlock)(float uploadProgress, float dowloadProgress);

/**
This block provides the ability to take the NSData that the task received and transform it into another object.

@param data The NSData object to be transformed.

@return Returns the transformed data.
*/
typedef id (^FDRequestClientTaskDataParserBlock)(NSData *data);

/**
This block provides the ability to transform an object that was returned from the data parser into a local entity.

@param object The object to transform.

@return Returns the transformed object.
*/
typedef id (^FDRequestClientTaskTransformBlock)(id object);

/**
This block is called when the task has finished loading and the response object has been constructed.

@param urlResponse The response of the request.
*/
typedef void (^FDRequestClientTaskCompletionBlock)(FDURLResponse *urlResponse);


#pragma mark - Class Interface

/**
FDRequestClientTask is a wrapper class around NSURLSessionTask which encapsulates all the boilerplate work around handling the response for NSURLSessionDataDelegate methods.

It provides a similar interface to NSURLSessionTask to suspend, resume and cancel tasks. But it has a block based interface to notify the user when the task has finished 
*/
@interface FDRequestClientTask : NSObject


#pragma mark - Properties

/**
The NSURLSessionTask that is backing the request client task. It should not be modified in any manner. It is provided only as a point of reference.
*/
@property (nonatomic, readonly) NSURLSessionTask *urlSessionTask;

/**
By default completion blocks are called on the main thread. Set this property to NO if you want the completion blocks to be called on the same thread that the NSURLSession delegate methods are called on.
*/
@property (nonatomic, assign) BOOL callCompletionBlockOnMainThread;


#pragma mark - Instance Methods

/**
Attemtps to add the completion block to the list of blocks to be called when the request finishes loading.

It is possible that this method is called while the current list of completion blocks is being enumerated over and called. In this scenario the completion block cannot be added and the method will return NO to indicate this.

@param completionBlock The completion block to add.

@return Returns YES if the completion block was added succesfully otherwise NO.
*/
- (BOOL)addCompletionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;

/**
Temporarily suspends the task. While the task is suspended it does not product any network traffice and cannot time out.
*/
- (void)suspend;

/**
Resumes the task, if it is suspended.
*/
- (void)resume;

/**
Attempts to cancels the task. If the cancellation was successful the status propery of the urlResponse will be set to FDURLResponseStatusCancelled.
*/
- (void)cancel;


@end