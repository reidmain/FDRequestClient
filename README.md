# Overview
Anyone who has worked with RESTful services in Objective-C knows that there is a lot of boilerplate code associated with it. Even with the advent of NSURLSession there is still a lot of similar code that most people end up writing to get their app parsing data from their web services.

This project is an attempt to distill all that boilerplate code down into a single class that allows you to package all of the information for a network request into a single object and load it using a block-based API.

The main classes this project is compromised of are:
1. FDHTTPRequest
2. FDRequestClient
3. FDRequestClientTask
4. FDURLResponse

FDHTTPRequest is a simple wrapper object around NSURLRequest. It handles a lot of the common code you have to write when attempting to create a HTTP NSURLRequest such as setting header fields, setting query parameters, setting the message body, converting the message body to JSON and then setting the appropriate header field, etc.

FDRequestClient is the main workhorse of this project. It takes in either a FDHTTPRequest or NSURLRequest and provides a series of blocks for all the callbacks that can possibly occur while the request is being loaded.

FDRequestClientTask is a wrapper class around NSURLSessionTask. It handles all the processing of data that is received during the loading process and has a interface to start, stop and pause the loading of the request. It also has a block-based API for notifying you when the task finishes loading.

FDURLResponse is a wrapper class around NSURLResponse. It simplifies access to some of the more common information you typically care about when a request finishes loading.

# Installation
There are two supported methods for FDRequestClient. Both methods assume your Xcode project is using modules.

### 1. Subprojects
1. Add the "FDRequestClient" project inside the "Framework Project" directory as a subproject or add it to your workspace.
2. Add "FDRequestClient (iOS/Mac)" to the "Target Dependencies" section of your target.
3. Use "@import FDRequestClient" inside any file that will be using FDRequestClient.

### 2. CocoaPods
Simply add `pod "FDRequestClient", "~> 1.0.0"` to your Podfile.

# Examples
There is an iOS example project included with this repo that shows you how to query both the Twitter API using using iOS accounts and the GitHub API.

But let's show a quick example below of how to construct a simple HTTP request against something.

	NSURL *url = [NSURL URLWithString: @"https://api.twitch.tv/kraken/search/games"];
	
	FDHTTPRequest *httpRequest = [[FDHTTPRequest alloc] 
		initWithURL: url];
	[httpRequest setValue: @"Monster Hunter" 
		forParameter: @"query"];
	[httpRequest setValue: @"suggest" 
		forParameter: @"type"];
	[httpRequest setValue: @"true" 
		forParameter: @"live"];
	
	FDRequestClient *requestClient = [FDRequestClient new];
	[requestClient loadHTTPRequest: httpRequest 
		authorizationBlock: nil 
		progressBlock: ^(float uploadProgress, float dowloadProgress)
			{
				NSLog(@"Downloading: %.2f%%", dowloadProgress * 100);
			} 
		dataParserBlock: nil 
		transformBlock: ^id(id object)
			{
				id firstResult = nil;
				
				if ([object isKindOfClass: [NSDictionary class]] == YES)
				{
					firstResult = object[@"games"][0];
				}
				
				return firstResult;
			} 
		completionBlock: ^(FDURLResponse *urlResponse)
			{
				NSLog(@"First Result:\t%@", urlResponse.content);
			}];
