#pragma mark Forward Declarations

@class FDRequestClient;


#pragma mark - Protocol

@protocol FDRequestClientDelegate<NSObject>


#pragma mark - Optional Methods

@optional

- (BOOL)requestClient: (FDRequestClient *)requestClient 
	canParseDataType: (NSString *)dataType;
- (id)requestClient: (FDRequestClient *)requestClient 
	parseData: (NSData *)data 
	withDataType: (NSString *)type;


@end