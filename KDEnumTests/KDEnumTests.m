//
//  KDEnumTests.m
//  KDEnumTests
//
//  Created by kealdish on 2020/9/20.
//  Copyright © 2020 Kealdish. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KDEnum/KDEnum.h>

KD_ENUM(NSUInteger, KSSearchType,
KSSearchTypeDefault = 0,
KSSearchType1 = 1,
KSSearchType2,
KSSearchType3);

@interface KDEnumTests : XCTestCase

@end

@implementation KDEnumTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    BOOL isValid1 = KSEnumIsValidKSSearchType(0);
    XCTAssertTrue(isValid1);
    BOOL isValid2 = KSEnumIsValidKSSearchType(2);
    XCTAssertTrue(isValid2);
    BOOL isValid3 = KSEnumIsValidKSSearchType(6);
    XCTAssertFalse(isValid3);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
