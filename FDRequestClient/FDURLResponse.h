@import Foundation;


#pragma mark Enumerations

typedef enum
{
	FDURLResponseStatusSucceed,
	FDURLResponseStatusFailed,
	FDURLResponseStatusCancelled
} FDURLResponseStatus;


#pragma mark - Class Interface

/**
The FDURLResponse class encapsulates the metadata associated with loading a request from the FDRequestClient.
*/
@interface FDURLResponse : NSObject


#pragma mark - Properties

/**
The status of the response.

@see FDURLResponseStatus
*/
@property (nonatomic, readonly) FDURLResponseStatus status;

/**
The fully transformed content of the response.
*/
@property (nonatomic, strong, readonly) id content;

/**
Not if any error occured while loading the response.
*/
@property (nonatomic, strong, readonly) NSError *error;

/**
The NSURLResponse object that was returned.
*/
@property (nonatomic, strong, readonly) NSURLResponse *rawURLResponse;


@end