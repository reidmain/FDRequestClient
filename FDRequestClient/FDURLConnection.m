#import "FDURLConnection.h"
#import "FDURLResponse+Private.h"


#pragma mark Constants

#define UnknownDataLength ((long long)-1)


#pragma mark -
#pragma mark Class Definition

@implementation FDURLConnection
{
	@private NSURLRequest *_urlRequestToLoad;
	@private FDURLRequest *_urlRequest;
	@private FDURLRequestType _urlRequestType;
	@private BOOL _connectionLoaded;
	@private BOOL _connectionOpen;
	@private BOOL _connectionCancelled;
	@private NSURLResponse *_rawURLResponse;
	@private long long _expectedDataLength;
	@private NSMutableData *_receivedData;
	@private NSError *_error;
	
	@private FDURLConnectionAuthorizationBlock _authorizationBlock;
	@private FDURLConnectionProgressBlock _progressBlock;
}


#pragma mark -
#pragma mark Constructors

- (id)initWithURLRequest: (NSURLRequest *)urlRequest 
	urlRequestType: (FDURLRequestType)urlRequestType
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_urlRequestToLoad = [urlRequest retain];
	_urlRequest = nil;
	_urlRequestType = [urlRequestType copy];
	_connectionLoaded = NO;
	_connectionOpen = NO;
	_connectionCancelled = NO;
	_rawURLResponse = nil;
	_expectedDataLength = UnknownDataLength;
	_receivedData = nil;
	_error = nil;
	
	_authorizationBlock = nil;
	_progressBlock = nil;
	
	// Return initialized instance.
	return self;
}

- (id)initWithURLRequest: (FDURLRequest *)urlRequest
{
	// Abort if base initializer fails.
	if ((self = [self initWithURLRequest: nil 
		urlRequestType: urlRequest.type]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_urlRequest = [urlRequest retain];
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc
{
	// Release instance variables.
	[_urlRequest release];
	[_urlRequestType release];
	[_rawURLResponse release];
	[_receivedData release];
	[_error release];
	
	[_authorizationBlock release];
	[_progressBlock release];
	
	// Call the base destructor.
	[super dealloc];
}


#pragma mark -
#pragma mark Public Methods

- (FDURLResponse *)loadWithAuthorizationBlock: (FDURLConnectionAuthorizationBlock)authorizationBlock 
	progressBlock: (FDURLConnectionProgressBlock)progessBlock 
	dataParserBlock: (FDURLConnectionDataParserBlock)dataParserBlock 
	transformBlock: (FDURLConnectionTransformBlock)transformBlock
{
	// If the connection has already been loaded, don't allow it to load again.
	if (_connectionLoaded == YES)
	{
		[NSException raise: NSInternalInconsistencyException 
			format: @"%@ has already being loaded.\n%s", 
				self, 
				__PRETTY_FUNCTION__];
	}
	
	_connectionLoaded = YES;
	
	// Generate the URL request to load, if it does not already exist.
	if (_urlRequestToLoad == nil)
	{
		_urlRequestToLoad = [[_urlRequest rawURLRequest] retain];
	}
	
	// Load the data from disk if the URL is a file.
	if ([[_urlRequestToLoad URL] isFileURL] == YES)
	{
		_receivedData = [NSData dataWithContentsOfURL: [_urlRequestToLoad URL]];
	}
	// Otherwise, open up a URL connection to download the response for the URL.
	else
	{
		[_authorizationBlock release];
		_authorizationBlock = [authorizationBlock copy];
		[_progressBlock release];
		_progressBlock = [progessBlock copy];
		
		NSURLConnection *urlConnection = [[NSURLConnection alloc] 
			initWithRequest: _urlRequestToLoad 
				delegate: self 
				startImmediately: NO];
		
		NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
		NSString *runLoopMode = NSDefaultRunLoopMode;
		
		[urlConnection scheduleInRunLoop: runLoop 
			forMode: runLoopMode];
		
		_connectionOpen = YES;
		
		[urlConnection start];
		
		// Block execution until the URL connection has finished or is cancelled.
		NSDate *distantFuture = [NSDate distantFuture];
		while (_connectionOpen == YES 
			&& _connectionCancelled == NO 
			&& [runLoop runMode: runLoopMode 
					beforeDate: distantFuture]);
		
		if (_connectionCancelled == YES)
		{
			[urlConnection cancel];
		}
		
		[urlConnection release];
		
		[_authorizationBlock release];
		[_progressBlock release];
	}
	
	id responseContent = nil;
	
	// Pass the received data into the data parser block, if it exists.
	if (dataParserBlock != nil)
	{
		responseContent = dataParserBlock(_receivedData);
	}
	// Otherwise, parse the received data into the specified format.
	else
	{
		if ([_urlRequestType isEqualToString: FDURLRequestTypeRaw] == YES)
		{
			responseContent = _receivedData;
		}
		else if ([_urlRequestType isEqualToString: FDURLRequestTypeString] == YES)
		{
			NSString *receivedDataAsString = [[NSString alloc] 
				initWithData: _receivedData 
					encoding: NSUTF8StringEncoding];
			
			responseContent = [receivedDataAsString autorelease];
		}
		else if ([_urlRequestType isEqualToString: FDURLRequestTypeImage] == YES)
		{
			responseContent = [UIImage imageWithData: _receivedData];
		}
		else if ([_urlRequestType isEqualToString: FDURLRequestTypeJSON] == YES)
		{
			// TODO: can't call this if data is nil. Happened when connection failed.
			responseContent = [NSJSONSerialization JSONObjectWithData: _receivedData 
				options: NSJSONReadingAllowFragments 
				error: nil];
		}
		else
		{
			[NSException raise: NSInternalInconsistencyException 
				format: @"Unsupported request type: %@\n%s", 
					_urlRequestType, 
					__PRETTY_FUNCTION__];
		}
	}
	
	// If it exists, call the transform block on the parsed content.
	if (transformBlock != nil)
	{
		responseContent = transformBlock(responseContent);
	}
	
	FDURLResponseStatus status = FDURLResponseStatusSucceed;
	
	if (_connectionCancelled == YES)
	{
		status = FDURLResponseStatusCancelled;
	}
	else if (_error != nil)
	{
		status = FDURLResponseStatusFailed;
	}
	
	FDURLResponse *urlResponse = [[[FDURLResponse alloc] 
		_initWithStatus: status 
			content: responseContent 
			error: _error 
			rawURLResponse: _rawURLResponse] 
				autorelease];
	
	return urlResponse;
}

- (FDURLResponse *)loadWithDataParserBlock: (FDURLConnectionDataParserBlock)dataParserBlock
	transformBlock: (FDURLConnectionTransformBlock)transformBlock
{
	FDURLResponse *urlResponse = [self loadWithAuthorizationBlock: nil 
		progressBlock: nil 
		dataParserBlock: dataParserBlock 
		transformBlock: transformBlock];
	
	return urlResponse;
}

- (FDURLResponse *)loadWithTransformBlock: (FDURLConnectionTransformBlock)transformBlock
{
	FDURLResponse *urlResponse = [self loadWithAuthorizationBlock: nil 
		progressBlock: nil 
		dataParserBlock: nil 
		transformBlock: transformBlock];
	
	return urlResponse;
}

- (FDURLResponse *)load
{
	FDURLResponse *urlResponse = [self loadWithAuthorizationBlock: nil 
		progressBlock: nil 
		dataParserBlock: nil 
		transformBlock: nil];
	
	return urlResponse;
}

- (void)cancel
{
	_connectionCancelled = YES;
}


#pragma mark -
#pragma mark NSURLConnectionDataDelegate Methods

- (void)connection: (NSURLConnection *)connection 
	didReceiveResponse: (NSURLResponse *)response
{
	// Ignore the response if the connection has been cancelled.
	if (_connectionCancelled == YES)
	{
		return;
	}
	
	// Store URL response so it can be returned.
	[_rawURLResponse release];
	_rawURLResponse = [response retain];
	
	// Store the expected data length, if it is known.
	long long expectedContentLength = [response expectedContentLength];
	
	NSInteger capacity = 0;
	
	if (expectedContentLength != NSURLResponseUnknownLength)
	{
		_expectedDataLength = expectedContentLength;
		
		capacity = (NSUInteger)_expectedDataLength;
	}
	
	// Create container to store received data.
	[_receivedData release];
	_receivedData = [[NSMutableData alloc] 
		initWithCapacity: capacity];
}

- (void)connection: (NSURLConnection *)connection 
	didReceiveData: (NSData *)data
{
	// Ignore received data if the connection has been cancelled.
	if (_connectionCancelled == YES)
	{
		return;
	}
	
	// Append received 
	[_receivedData appendData: data];
	
	// If the expected data length is known, calculate the current progress of the download.
	if (_expectedDataLength != UnknownDataLength 
		&& _progressBlock != nil)
	{
		float progress = [_receivedData length] / (float)_expectedDataLength;
		
		_progressBlock(progress);
	}
}

- (void)connectionDidFinishLoading: (NSURLConnection *)connection
{
	// Update flag to indicate that the URL connection has been closed. This is done to allow the blocking call on the run loop to continue.
	_connectionOpen = NO;
}


#pragma mark -
#pragma mark NSURLConnectionDelegate Methods

- (void)connection: (NSURLConnection *)connection 
	willSendRequestForAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	// If an authorization block exists pass the challenge into it. Otherwise, continue on without passing credentials to the authorization challenge.
	if (_authorizationBlock != nil)
	{
		_authorizationBlock(challenge);
	}
	else
	{
		[challenge.sender continueWithoutCredentialForAuthenticationChallenge: challenge];
	}
}

- (void)connection: (NSURLConnection *)connection 
	didFailWithError: (NSError *)error
{
	// If the connection fails, update flag to indicate that the URL connection has been closed and store the error so it can be returned.
	_connectionOpen = NO;
	
	[_error release];
	_error = [error retain];
}


@end // @implementation FDURLConnection