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
#import <ulibsms/UMSMS.h>

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
    NSString *s = @"440B917368962108F8000871904131612500700500036F03020070002E0063006800650072006E007900730068006500760040006C006900730074002E00720075002E0020041D0435043F0440043004320438043B044C043D043E003F00A0041F043E04410435044204380442043500200441044204400430043D04380446044300A0";
    NSData *d = [s unhexedData];
    UMSMS *sms = [[UMSMS alloc]init];
    [sms decodePdu:d context:NULL];
    NSLog(@"%@",sms.text);
}


- (void)testEncoding8to7
{
	NSString *s = @"Verify";
	NSData *d = [s dataUsingEncoding:NSISOLatin1StringEncoding];

	NSString *s2 = @"D6B23C6DCE03";
	NSData *d2 = [s2 unhexedData];
	NSData *d_encoded = [d gsm8to7withNibbleLengthPrefix];
	XCTAssert([d_encoded isEqual:d2],@"Data doesnt match");
	
}
@end
