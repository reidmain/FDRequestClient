#import "FDHTTPRequest.h"
#import "FDNullOrEmpty.h"
#import "NSDictionary+URLEncode.h"


#pragma mark Constants

NSString * const FDHTTPRequestMethodGet = @"GET";
NSString * const FDHTTPRequestMethodPost = @"POST";
NSString * const FDHTTPRequestMethodDelete = @"DELETE";
NSString * const FDHTTPRequestMethodPut = @"PUT";


#pragma mark -
#pragma mark Class Definition

@implementation FDHTTPRequest
{
	@private __strong NSMutableDictionary *_httpHeaderFields;
	@private __strong NSMutableDictionary *_parameters;
}


#pragma mark -
#pragma mark Properties

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

-(void)setMessageBody: (NSData *)messageBody
{
	if (_messageBody != messageBody)
	{
		// Clear message body provider. It and message body are mutually exclusive.
		_messageBodyProvider = nil;
		
		// Release old value.
		_messageBody = nil;
		
		// Retain new value.
		_messageBody = messageBody;
	}
}

-(void)setMessageBodyProvider: (FDHTTPRequestMessageBodyProvider)messageBodyProvider
{
	if (_messageBodyProvider != messageBodyProvider)
	{
		// Clear message body. It and message body provider are mutually exclusive.
		_messageBody = nil;
		
		// Update message body provider.
		_messageBodyProvider = [messageBodyProvider copy];
	}
}


#pragma mark -
#pragma mark Constructors

- (id)initWithURL: (NSURL *)url
{
	// Abort if base initializer fails.
	if ((self = [super initWithURL: url]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_method = [FDHTTPRequestMethodGet copy];
	_httpHeaderFields = [[NSMutableDictionary alloc] 
		init];
	_parameters = [[NSMutableDictionary alloc] 
		init];
	_messageBody = nil;
	_messageBodyProvider = nil;
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Public Methods

- (void)setValue: (NSString *)value 
    forHTTPHeaderField: (NSString *)field
{
	if (FDIsEmpty(field) == NO)
	{
		[_httpHeaderFields setValue: value 
			forKey: field];
	}
}

- (void)setValue: (NSString *)value 
	forParameter: (NSString *)parameter
{
	if (FDIsEmpty(parameter) == NO)
	{
		[_parameters setValue: value 
			forKey: parameter];
	}
}


#pragma mark -
#pragma mark Overridden Methods

- (NSURLRequest *)rawURLRequest
{
	// If any query parameters exist, add them to the string of the URL.
	NSURL *url = nil;
	if (FDIsEmpty(_parameters) == NO)
	{
		NSString *queryString = [_parameters urlEncode];
		
		NSString *urlAsString = nil;
		
		if (FDIsEmpty([self.url query]) == YES)
		{
			urlAsString = [NSString stringWithFormat: @"%@?%@", 
				self.url, 
				queryString];
		}
		else
		{
			urlAsString = [NSString stringWithFormat: @"%@?%@", 
				self.url, 
				queryString];
		}
		
		url = [[NSURL alloc] 
			initWithString: urlAsString];
	}
	else
	{
		url = self.url;
	}
	
	// Create a mutable URL request for the URL and add the HTTP header fields to it.
	NSMutableURLRequest *rawURLRequest = [[NSMutableURLRequest alloc] 
		initWithURL: url 
			cachePolicy: self.cachePolicy 
			timeoutInterval: self.timeoutInterval];
	
	[rawURLRequest setAllHTTPHeaderFields: _httpHeaderFields];
	
	// Load the message body (if necessary) and add it to the URL request.
	NSData *messageBody = nil;
	
	if (_messageBodyProvider != nil)
	{
		messageBody = _messageBodyProvider();
	}
	else
	{
		messageBody = _messageBody;
	}
	
	[rawURLRequest setHTTPBody: messageBody];
	
	return rawURLRequest;
}


@end // @implementation FDHTTPRequest