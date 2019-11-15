//
//  DemoTests.m
//  DemoTests
//
//  Created by Zero.D.Saber on 2019/10/10.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZDFlexLayoutKit.h"

@interface DemoTests : XCTestCase

@end

@implementation DemoTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testLayoutWithDisableYoga {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 75)];

    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    [view zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexBasis(YGValueZero).flexGrow(1);
    }];
    [container addChild:view];

    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(10, 20, 30, 40)];
    [container addChild:view2];

    [container calculateLayoutPreservingOrigin:YES];

    XCTAssertEqual(50, view.frame.size.width);
    XCTAssertEqual(75, view.frame.size.height);

    XCTAssertEqual(10, view2.frame.origin.x);
    XCTAssertEqual(20, view2.frame.origin.y);
    XCTAssertEqual(30, view2.frame.size.width);
    XCTAssertEqual(40, view2.frame.size.height);
}

@end
