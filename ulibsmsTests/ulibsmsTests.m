//
//  ulibsmsTests.m
//  ulibsmsTests
//
//  Copyright © 2017 Andreas Fink (andreas@fink.org). All rights reserved.
//
// This source is dual licensed either under the GNU GENERAL PUBLIC LICENSE
// Version 3 from 29 June 2007 and other commercial licenses available by
// the author.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <ulib/ulib.h>
#import "UMSMS.h"

@interface ulibsmsTests : XCTestCase

@end

@implementation ulibsmsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void) testDecoding
{
    NSString *s = @"240B919799329660F700007190010190822150CC32FD3407D9D3E4F21B344687E9A0B09B0CA297F174D0DB0D4AB7DF21D0B14C07D1D16590595E2E83C27038084DA7C3E7BAD7CB7D93D96AAE301CEE3ABFDFAE33FB053FD6D7";
    NSData *d = [s unhexedData];
    UMSMS *sms = [[UMSMS alloc]init];
    [sms decodePdu:d context:NULL];
 
    UMSynchronizedSortedDictionary *o = sms.objectValue;

    NSLog(@"%@",o);
}
@end
