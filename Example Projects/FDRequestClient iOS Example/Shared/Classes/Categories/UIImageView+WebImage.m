#import "UIImageView+WebImage.h"
#import "FDInMemoryCache.h"
#import <objc/runtime.h>


#pragma mark Class Definition

@implementation UIImageView (WebImage)

static void * const _imageURLKey;
static void * const _loadImageOperationKey;


#pragma mark -
#pragma mark Public Methods

- (void)loadImageFromURL: (NSURL *)imageURL 
	placeholderImage: (UIImage *)placeholderImage
{
	static FDRequestClient *requestClient = nil;
	static FDInMemoryCache *inMemoryCache = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, 
		^{
			requestClient = [[FDRequestClient alloc] 
				initWithSharedOperationQueue: NO];
			
			inMemoryCache = [[FDInMemoryCache alloc] 
				init];
			
			requestClient.cache = inMemoryCache;
		});
	
	NSURL *currentImageURL = objc_getAssociatedObject(self, 
		&_imageURLKey);
	
	if ([currentImageURL isEqual: imageURL] == NO)
	{
		self.image = placeholderImage;
		
		FDURLConnectionOperation *currentLoadImageOperation = objc_getAssociatedObject(self, 
			&_loadImageOperationKey);
		
		[currentLoadImageOperation cancel];
		
		FDHTTPRequest *httpRequest = [[FDHTTPRequest alloc] 
			initWithURL: imageURL];
		httpRequest.type = FDURLRequestTypeImage;
		
		FDURLConnectionOperation *loadImageOperation = [requestClient loadURLRequest: httpRequest 
			authorizationBlock: nil 
			progressBlock: nil 
			dataParserBlock: nil 
			transformBlock:^id(id data)
			{
				return data;
			} 
			completionBlock: ^(FDURLResponse *urlResponse)
			{
				if (urlResponse.status == FDURLResponseStatusSucceed)
				{
					self.image = urlResponse.content;
					
					objc_setAssociatedObject(self, 
						&_loadImageOperationKey, 
						nil, 
						OBJC_ASSOCIATION_RETAIN_NONATOMIC);
				}
			}];
		
		objc_setAssociatedObject(self, 
			&_imageURLKey, 
			imageURL, 
			OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		
		objc_setAssociatedObject(self, 
			&_loadImageOperationKey, 
			loadImageOperation, 
			OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
}


@end // @implementation UIImageView (WebImage)