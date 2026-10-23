//
//  AsyncLayoutTests.m
//  DemoTests
//
//  Created by Zero.D.Saber on 2024/12/1.
//

#import <XCTest/XCTest.h>
#import "ZDFlexLayoutKit.h"

@interface AsyncLayoutTests : XCTestCase

@property (nonatomic, strong) UIView *rootView;

@end

@implementation AsyncLayoutTests

- (void)setUp {
    [super setUp];
    self.rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
}

- (void)tearDown {
    self.rootView = nil;
    [super tearDown];
}

#pragma mark - Sync Mode Tests

- (void)testSyncMode_BasicLayout {
    UIView *container = self.rootView;
    [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
    }];

    UIView *child = UIView.new;
    [child zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.width(YGPointValue(100)).height(YGPointValue(50));
    }];
    [container addChild:child];

    [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeSync
                                  preservingOrigin:YES
                              dimensionFlexibility:ZDDimensionFlexibilityFlexibleNone];

    XCTAssertEqual(child.frame.size.width, 100);
    XCTAssertEqual(child.frame.size.height, 50);
    XCTAssertEqual(child.frame.origin.x, 0);
    XCTAssertEqual(child.frame.origin.y, 0);
}

- (void)testSyncMode_FlexGrow {
    UIView *container = self.rootView;
    [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionRow);
    }];

    UIView *child1 = UIView.new;
    [child1 zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexGrow(1);
    }];
    [container addChild:child1];

    UIView *child2 = UIView.new;
    [child2 zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexGrow(2);
    }];
    [container addChild:child2];

    [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeSync
                                  preservingOrigin:YES
                              dimensionFlexibility:ZDDimensionFlexibilityFlexibleNone];

    XCTAssertEqual(child1.frame.size.width, 125);
    XCTAssertEqual(child2.frame.size.width, 250);
}

- (void)testSyncMode_LabelMeasurement {
    UIView *container = self.rootView;
    [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
    }];

    UILabel *label = UILabel.new;
    label.text = @"Hello World";
    label.font = [UIFont systemFontOfSize:16];
    [label zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
    }];
    [container addChild:label];

    [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeSync
                                  preservingOrigin:YES
                              dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];

    XCTAssertGreaterThan(label.frame.size.width, 0);
    XCTAssertGreaterThan(label.frame.size.height, 0);
}

#pragma mark - RunLoop Idle Mode Tests

- (void)testRunloopIdleMode_BasicLayout {
    UIView *container = self.rootView;
    [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
    }];

    UIView *child = UIView.new;
    [child zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.width(YGPointValue(200)).height(YGPointValue(100));
    }];
    [container addChild:child];

    [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeRunloopIdle
                                  preservingOrigin:YES
                              dimensionFlexibility:ZDDimensionFlexibilityFlexibleNone];

    // RunLoop idle: layout is deferred. Run the runloop to trigger execution.
    XCTestExpectation *expectation = [self expectationWithDescription:@"RunLoop idle layout applied"];
    dispatch_async(dispatch_get_main_queue(), ^{
        // After one runloop cycle, the observer should have fired
        dispatch_async(dispatch_get_main_queue(), ^{
            [expectation fulfill];
        });
    });

    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    XCTAssertEqual(child.frame.size.width, 200);
    XCTAssertEqual(child.frame.size.height, 100);
}

- (void)testRunloopIdleMode_MultipleChildren {
    UIView *container = self.rootView;
    [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
    }];

    UIView *child1 = UIView.new;
    [child1 zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.width(YGPointValue(375)).height(YGPointValue(44));
    }];
    [container addChild:child1];

    UIView *child2 = UIView.new;
    [child2 zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.width(YGPointValue(375)).height(YGPointValue(88));
    }];
    [container addChild:child2];

    [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeRunloopIdle
                                  preservingOrigin:YES
                              dimensionFlexibility:ZDDimensionFlexibilityFlexibleNone];

    XCTestExpectation *expectation = [self expectationWithDescription:@"RunLoop idle multi-child"];
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [expectation fulfill];
        });
    });
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    XCTAssertEqual(child1.frame.origin.y, 0);
    XCTAssertEqual(child1.frame.size.height, 44);
    XCTAssertEqual(child2.frame.origin.y, 44);
    XCTAssertEqual(child2.frame.size.height, 88);
}

#pragma mark - Background Thread Mode Tests

- (void)testBackgroundThreadMode_BasicLayout {
    UIView *container = self.rootView;
    [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
    }];

    UIView *child = UIView.new;
    [child zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.width(YGPointValue(100)).height(YGPointValue(50));
    }];
    [container addChild:child];

    [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeBackgroundThread
                                  preservingOrigin:YES
                              dimensionFlexibility:ZDDimensionFlexibilityFlexibleNone];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Background thread layout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    XCTAssertEqual(child.frame.size.width, 100);
    XCTAssertEqual(child.frame.size.height, 50);
}

- (void)testBackgroundThreadMode_LabelMeasurement {
    UIView *container = self.rootView;
    [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
        make.width(YGPointValue(375));
    }];

    UILabel *label = UILabel.new;
    label.text = @"Async layout test label";
    label.font = [UIFont systemFontOfSize:16];
    [label zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
    }];
    [container addChild:label];

    [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeBackgroundThread
                                  preservingOrigin:YES
                              dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Background label measurement"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    XCTAssertGreaterThan(label.frame.size.width, 0);
    XCTAssertGreaterThan(label.frame.size.height, 0);
}

- (void)testBackgroundThreadMode_ImageViewMeasurement {
    UIView *container = self.rootView;
    [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
    }];

    UIGraphicsBeginImageContext(CGSizeMake(60, 40));
    UIImage *testImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIImageView *imageView = [[UIImageView alloc] initWithImage:testImage];
    [imageView zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
    }];
    [container addChild:imageView];

    [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeBackgroundThread
                                  preservingOrigin:YES
                              dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Background imageview measurement"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    XCTAssertEqual(imageView.frame.size.width, 60);
    XCTAssertEqual(imageView.frame.size.height, 40);
}

- (void)testBackgroundThreadMode_CustomViewSizeThatFits {
    UIView *container = self.rootView;
    [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
    }];

    UISwitch *toggle = UISwitch.new;
    [toggle zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
    }];
    [container addChild:toggle];

    [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeBackgroundThread
                                  preservingOrigin:YES
                              dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Background custom view"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    XCTAssertGreaterThan(toggle.frame.size.width, 0);
    XCTAssertGreaterThan(toggle.frame.size.height, 0);
}

- (void)testBackgroundThreadMode_FlexGrow {
    UIView *container = self.rootView;
    [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionRow);
    }];

    UIView *child1 = UIView.new;
    [child1 zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexGrow(1).height(YGPointValue(50));
    }];
    [container addChild:child1];

    UIView *child2 = UIView.new;
    [child2 zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexGrow(2).height(YGPointValue(50));
    }];
    [container addChild:child2];

    [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeBackgroundThread
                                  preservingOrigin:YES
                              dimensionFlexibility:ZDDimensionFlexibilityFlexibleNone];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Background flexGrow"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    XCTAssertEqual(child1.frame.size.width, 125);
    XCTAssertEqual(child2.frame.size.width, 250);
}

#pragma mark - Consistency Tests (Sync vs Async produce same results)

- (void)testConsistency_SyncAndBackgroundProduceSameFrames {
    // Build identical layout trees and compare results
    UIView *(^buildTree)(void) = ^{
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
        [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
            make.isEnabled(YES);
            make.flexDirection(YGFlexDirectionColumn);
            make.padding(YGPointValue(16));
        }];

        UILabel *label = UILabel.new;
        label.text = @"Test consistency";
        label.font = [UIFont systemFontOfSize:14];
        [label zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
            make.isEnabled(YES);
            make.marginBottom(YGPointValue(8));
        }];
        [container addChild:label];

        UIView *row = UIView.new;
        [row zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
            make.isEnabled(YES);
            make.flexDirection(YGFlexDirectionRow);
            make.height(YGPointValue(80));
        }];
        [container addChild:row];

        UIView *red = UIView.new;
        [red zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
            make.isEnabled(YES).flexGrow(1);
        }];
        [row addChild:red];

        UIView *blue = UIView.new;
        [blue zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
            make.isEnabled(YES).flexGrow(2);
        }];
        [row addChild:blue];

        return container;
    };

    // Sync calculation
    UIView *syncContainer = buildTree();
    [syncContainer.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeSync
                                      preservingOrigin:YES
                                  dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];

    // Async calculation
    UIView *asyncContainer = buildTree();
    [asyncContainer.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeBackgroundThread
                                       preservingOrigin:YES
                                   dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Async done"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    // Compare: label frames
    UILabel *syncLabel = (UILabel *)syncContainer.children.firstObject;
    UILabel *asyncLabel = (UILabel *)asyncContainer.children.firstObject;
    XCTAssertTrue(CGRectEqualToRect(syncLabel.frame, asyncLabel.frame),
                  @"Label frames differ: sync=%@ async=%@",
                  NSStringFromCGRect(syncLabel.frame), NSStringFromCGRect(asyncLabel.frame));

    // Compare: row container frames
    UIView *syncRow = (UIView *)syncContainer.children[1];
    UIView *asyncRow = (UIView *)asyncContainer.children[1];
    XCTAssertTrue(CGRectEqualToRect(syncRow.frame, asyncRow.frame),
                  @"Row frames differ: sync=%@ async=%@",
                  NSStringFromCGRect(syncRow.frame), NSStringFromCGRect(asyncRow.frame));
}

#pragma mark - Style Pollution Tests

- (void)testBackgroundThreadMode_DoesNotPollutNodeStyle {
    UIView *container = self.rootView;
    [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
    }];

    UILabel *label = UILabel.new;
    label.text = @"Style pollution test";
    label.font = [UIFont systemFontOfSize:16];
    [label zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
    }];
    [container addChild:label];

    // Record original style
    YGValue widthBefore = label.flexLayout.width;
    YGValue heightBefore = label.flexLayout.height;

    // Run background layout
    [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeBackgroundThread
                                  preservingOrigin:YES
                              dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Style pollution check"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    // Verify style is NOT polluted
    YGValue widthAfter = label.flexLayout.width;
    YGValue heightAfter = label.flexLayout.height;

    XCTAssertEqual(widthBefore.unit, widthAfter.unit, @"Width unit changed after async layout");
    XCTAssertEqual(widthBefore.value, widthAfter.value, @"Width value changed after async layout");
    XCTAssertEqual(heightBefore.unit, heightAfter.unit, @"Height unit changed after async layout");
    XCTAssertEqual(heightBefore.value, heightAfter.value, @"Height value changed after async layout");
}

- (void)testBackgroundThreadMode_SubsequentSyncLayoutWorks {
    UIView *container = self.rootView;
    [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
    }];

    UILabel *label = UILabel.new;
    label.text = @"First pass";
    label.font = [UIFont systemFontOfSize:16];
    [label zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
    }];
    [container addChild:label];

    // First: background async
    [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeBackgroundThread
                                  preservingOrigin:YES
                              dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];

    XCTestExpectation *expectation1 = [self expectationWithDescription:@"First async done"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation1 fulfill];
    });
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    CGRect frameAfterAsync = label.frame;
    XCTAssertGreaterThan(frameAfterAsync.size.width, 0);

    // Second: change text and recalculate synchronously
    label.text = @"Second pass with longer text content here";
    [label.flexLayout markDirty];
    [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeSync
                                  preservingOrigin:YES
                              dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];

    CGRect frameAfterSync = label.frame;
    XCTAssertGreaterThan(frameAfterSync.size.width, frameAfterAsync.size.width,
                         @"Sync layout after async should reflect new longer text");
}

#pragma mark - Legacy Mode Tests

- (void)testLegacyPreMeasureMode_BasicLayout {
    UIView *container = self.rootView;
    [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
    }];

    UIView *child = UIView.new;
    [child zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.width(YGPointValue(100)).height(YGPointValue(50));
    }];
    [container addChild:child];

    container.flexLayout.useLegacyPreMeasure = YES;
    [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeBackgroundThread
                                  preservingOrigin:YES
                              dimensionFlexibility:ZDDimensionFlexibilityFlexibleNone];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Legacy mode layout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    XCTAssertEqual(child.frame.size.width, 100);
    XCTAssertEqual(child.frame.size.height, 50);
}

#pragma mark - Virtual View (ZDFlexLayoutDiv) Tests

- (void)testBackgroundThreadMode_VirtualView {
    UIView *container = self.rootView;
    [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionColumn);
    }];

    ZDFlexLayoutDiv *div = ZDFlexLayoutDiv.new;
    [div zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.flexDirection(YGFlexDirectionRow);
        make.height(YGPointValue(60));
    }];
    [container addChild:div];

    UIView *left = UIView.new;
    [left zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES);
        make.width(YGPointValue(100));
    }];
    [div addChild:left];

    UIView *right = UIView.new;
    [right zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
        make.isEnabled(YES).flexGrow(1);
    }];
    [div addChild:right];

    [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeBackgroundThread
                                  preservingOrigin:YES
                              dimensionFlexibility:ZDDimensionFlexibilityFlexibleNone];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Background virtual view"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    XCTAssertEqual(left.frame.size.width, 100);
    XCTAssertEqual(left.frame.size.height, 60);
    XCTAssertEqual(right.frame.size.width, 275);
    XCTAssertEqual(right.frame.size.height, 60);
}

#pragma mark - Performance Tests

- (void)testPerformance_SyncMode {
    [self measureBlock:^{
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
        [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
            make.isEnabled(YES).flexDirection(YGFlexDirectionColumn);
        }];

        for (int i = 0; i < 100; i++) {
            UIView *child = UIView.new;
            [child zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
                make.isEnabled(YES);
                make.height(YGPointValue(44));
            }];
            [container addChild:child];
        }

        [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeSync
                                      preservingOrigin:YES
                                  dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];
    }];
}

- (void)testPerformance_BackgroundThreadMode {
    [self measureBlock:^{
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
        [container zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
            make.isEnabled(YES).flexDirection(YGFlexDirectionColumn);
        }];

        for (int i = 0; i < 100; i++) {
            UIView *child = UIView.new;
            [child zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
                make.isEnabled(YES);
                make.height(YGPointValue(44));
            }];
            [container addChild:child];
        }

        [container.flexLayout applyLayoutWithAsyncMode:ZDFlexLayoutAsyncModeBackgroundThread
                                      preservingOrigin:YES
                                  dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];

        XCTestExpectation *expectation = [self expectationWithDescription:@"perf"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [expectation fulfill];
        });
        [self waitForExpectationsWithTimeout:2.0 handler:nil];
    }];
}

@end
