#import "FDURLRequest.h"


#pragma mark Constants

NSString * const FDURLRequestTypeRaw = @"raw";
NSString * const FDURLRequestTypeString = @"string";
NSString * const FDURLRequestTypeImage = @"image";
NSString * const FDURLRequestTypeJSON = @"json";


#pragma mark - Class Definition

@implementation FDURLRequest
{
	@private __strong NSURLRequest *_rawURLRequest;
	@private __strong FDURLRequestType _type;
}


#pragma mark - Constructors

- (id)initWithURL: (NSURL *)url 
	timeoutInterval: (NSTimeInterval)timeoutInterval 
	cachePolicy: (NSURLRequestCachePolicy)cachePolicy
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_rawURLRequest = [[NSURLRequest alloc] initWithURL: url 
		cachePolicy: cachePolicy 
		timeoutInterval: timeoutInterval];
	_type = [FDURLRequestTypeRaw copy];
	
	// Return initialized instance.
	return self;
}

- (id)initWithURL: (NSURL *)url
{
	// Abort if base initializer fails.
	if ((self = [self initWithURL: url 
		timeoutInterval: 30.0 
		cachePolicy: NSURLRequestUseProtocolCachePolicy]) == nil)
	{
		return nil;
	}
	
	// Return initialized instance.
	return self;
}

- (id)initWithURLRequest: (NSURLRequest *)urlRequest
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_rawURLRequest = urlRequest;
	_type = [FDURLRequestTypeRaw copy];
	
	// Return initialized instance.
	return self;
}

#pragma mark - Properties

- (NSURL *)url
{
	NSURL *url = [_rawURLRequest URL];
	
	return url;
}

- (NSTimeInterval)timeoutInterval
{
	NSTimeInterval timeoutInterval = [_rawURLRequest timeoutInterval];
	
	return timeoutInterval;
}

- (NSURLRequestCachePolicy)cachePolicy
{
	NSURLRequestCachePolicy cachePolicy = [_rawURLRequest cachePolicy];
	
	return cachePolicy;
}

#pragma mark - Public Methods

- (NSURLRequest *)rawURLRequest;
{
	return _rawURLRequest;
}


@end