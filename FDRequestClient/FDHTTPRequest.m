#import "FDHTTPRequest.h"
#import <FDFoundationKit/FDNullOrEmpty.h>
#import <FDFoundationKit/NSDictionary+URLEncode.h>


#pragma mark Constants

NSString * const FDHTTPRequestMethodGet = @"GET";
NSString * const FDHTTPRequestMethodPost = @"POST";
NSString * const FDHTTPRequestMethodDelete = @"DELETE";
NSString * const FDHTTPRequestMethodPut = @"PUT";


#pragma mark - Class Definition

@implementation FDHTTPRequest
{
	@private __strong NSMutableDictionary *_httpHeaderFields;
	@private __strong NSMutableDictionary *_parameters;
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
	_url = [url copy];
	_timeoutInterval = timeoutInterval;
	_cachePolicy = cachePolicy;
	_method = [FDHTTPRequestMethodGet copy];
	_httpHeaderFields = [[NSMutableDictionary alloc] 
		init];
	_parameters = [[NSMutableDictionary alloc] 
		init];
	_messageBody = nil;
	
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


#pragma mark - Properties

- (NSDictionary *)httpHeaderFields
{
	NSDictionary *httpHeaderFields = [NSDictionary dictionaryWithDictionary: _httpHeaderFields];
	
	return httpHeaderFields;
}
- (void)setHttpHeaderFields: (NSDictionary *)httpHeaderFields
{
	[_httpHeaderFields removeAllObjects];
	
	[_httpHeaderFields addEntriesFromDictionary: httpHeaderFields];
}

- (NSDictionary *)parameters
{
	NSDictionary *parameters = [NSDictionary dictionaryWithDictionary: _parameters];
	
	return parameters;
}
- (void)setParameters: (NSDictionary *)parameters
{
	[_parameters removeAllObjects];
	
	[_parameters addEntriesFromDictionary: parameters];
}


#pragma mark - Public Methods

- (NSURLRequest *)urlRequest
{
	// If any query parameters exist, add them to the string of the URL.
	NSURL *url = nil;
	if (FDIsEmpty(_parameters) == NO)
	{
		NSString *queryString = [_parameters urlEncode];
		
		NSString *urlAsString = nil;
		
		if (FDIsEmpty([_url query]) == YES)
		{
			urlAsString = [NSString stringWithFormat: @"%@?%@", 
				[_url absoluteString], 
				queryString];
		}
		else
		{
			urlAsString = [NSString stringWithFormat: @"%@&%@", 
				[_url absoluteString], 
				queryString];
		}
		
		url = [[NSURL alloc] 
			initWithString: urlAsString];
	}
	else
	{
		url = _url;
	}
	
	// Create a mutable URL request for the URL.
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] 
		initWithURL: url 
			cachePolicy: _cachePolicy 
			timeoutInterval: _timeoutInterval];
	
	// Set the HTTP method of the URL request.
	[urlRequest setHTTPMethod: _method];
	
	// Set the header fields of the URL request.
	[urlRequest setAllHTTPHeaderFields: _httpHeaderFields];
	
	// Set the message body of the URL request.
	[urlRequest setHTTPBody: _messageBody];
	
	return urlRequest;
}

- (void)setValue: (NSString *)value 
    forHTTPHeaderField: (NSString *)field
{
	[_httpHeaderFields setValue: value 
		forKey: field];
}

- (void)setValue: (id)value 
	forParameter: (NSString *)parameter
{
	[_parameters setValue: value 
		forKey: parameter];
}

- (void)setMessageBodyWithJSONObject: (id)object
{
	// Verify the object can be converted to JSON.
	if ([NSJSONSerialization isValidJSONObject: object] == NO)
	{
		[NSException raise: NSInternalInconsistencyException 
			format: @"%@ is not a valid JSON object: \n%s", 
				object, 
				__PRETTY_FUNCTION__];
		
		return;
	}
	
	// Attempt to serialize the object into the message body.
	NSError *error = nil;
	_messageBody = [NSJSONSerialization dataWithJSONObject: object 
		options: 0 
		error: &error];
	
	// If an error occured during serialization raise an exception.
	if (error != nil)
	{
		[NSException raise: NSInternalInconsistencyException 
			format: @"Error occured while attempting to serial JSON object %@: %@\n%s", 
				object, 
				error,
				__PRETTY_FUNCTION__];
	}
	// If the object was serialized property set the Content-Type header to JSON.
	else
	{
		[self setValue: @"application/json" 
			forHTTPHeaderField: @"Content-Type"];
	}
}


#pragma mark - Overridden Methods

- (NSString *)description
{
	NSString *description = [NSString stringWithFormat: @"<%@: %p; URL = %@; method = %@;\nheaders = %@;\nparameters = %@>", 
		[self class], 
		self, 
		[_url absoluteString], 
		_method, 
		_httpHeaderFields, 
		_parameters];
	
	return description;
}


@end