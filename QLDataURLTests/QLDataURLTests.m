//
//  QLDataURLTests.m
//  QLDataURLTests
//
//  Created by Peter Hosey on 2012-09-28.
//  Copyright (c) 2012 Peter Hosey. All rights reserved.
//

#import "QLDataURLTests.h"

#import "NSData+PRHDataURL.h"

@implementation QLDataURLTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testDataURL {
	NSString *testString = @"squeamish ossifrage";
	NSData *testInputData = [testString dataUsingEncoding:NSUTF8StringEncoding];
	NSURL *testOutputURL = [testInputData dataURLWithMimeType_PRH:@"text/plain"];
	NSString *testOutputURLString = [testOutputURL absoluteString];
	STAssertTrueNoThrow([testOutputURLString hasPrefix:@"data:text/plain;base64,"], @"data: URL doesn't start with correct and necessary prologue: %@", testOutputURLString);
	STAssertEqualObjects(testOutputURLString, @"data:text/plain;base64,c3F1ZWFtaXNoIG9zc2lmcmFnZQ==", @"data: URL is incorrect: %@", testOutputURLString);
	NSLog(@"Output: %@", testOutputURLString);
}

@end
