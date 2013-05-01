#pragma mark Class Interface

@interface UIImageView (WebImage)


#pragma mark - Instance Methods

- (void)loadImageFromURL: (NSURL *)imageURL 
	placeholderImage: (UIImage *)placeholderImage;


@end