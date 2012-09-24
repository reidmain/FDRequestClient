#pragma mark Enumerations

typedef enum
{
	FDURLResponseStatusSucceed,
	FDURLResponseStatusFailed,
	FDURLResponseStatusCancelled
} FDURLResponseStatus;


#pragma mark -
#pragma mark Class Interface

@interface FDURLResponse : NSObject


#pragma mark -
#pragma mark Properties

@property (nonatomic, readonly) FDURLResponseStatus status;
@property (nonatomic, readonly) id content;
@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly) NSURLResponse *rawURLResponse;


@end // @interface FDURLResponse