@import XCTest;

#import "FDHTTPRequest.h"


@interface FDHTTPRequestTests : XCTestCase

@end

@implementation FDHTTPRequestTests

- (void)testExample
{
	FDHTTPRequest *httpRequest = [FDHTTPRequest requestWithURL: [NSURL URLWithString: @"http://google.com"]];
	XCTAssertNotNil(httpRequest);
}

@end
