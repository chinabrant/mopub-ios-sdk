//
//  MPAdViewOverlayTests.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdViewOverlay.h"
#import "MPAdViewOverlay+Private.h"
#import "MPAdViewOverlayDelegateMock.h"

// For non-module targets, UIKit must be explicitly imported
// since MoPubSDK-Swift.h will not import it.
#if __has_include(<MoPubSDK/MoPubSDK-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <MoPubSDK/MoPubSDK-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "MoPubSDK-Swift.h"
#endif

@interface MPAdViewOverlayTests : XCTestCase

@end

@implementation MPAdViewOverlayTests

#pragma mark - Controls

- (void)testInitialControlState {
    MPAdViewOverlay *overlay = [[MPAdViewOverlay alloc] init];
    XCTAssertTrue(overlay.closeButton.hidden);
    XCTAssertTrue(overlay.skipButton.hidden);
    XCTAssertNil(overlay.timerView);
}

- (void)testShowCloseButton {
    MPAdViewOverlay *overlay = [[MPAdViewOverlay alloc] init];

    // Since there is no persistant timer, create one and make sure it's
    // set to nil after showing the close button.
    [overlay delayForDuration:5 showCountdownTimer:YES countdownTimerDelay:0];

    [overlay showCloseButton];

    XCTAssertFalse(overlay.closeButton.hidden);
    XCTAssertTrue(overlay.skipButton.hidden);
    XCTAssertNil(overlay.timerView);
}

- (void)testShowSkipButton {
    MPAdViewOverlay *overlay = [[MPAdViewOverlay alloc] init];

    // Since there is no persistant timer, create one and make sure it's
    // set to nil after showing the skip button.
    [overlay delayForDuration:5 showCountdownTimer:YES countdownTimerDelay:0];

    [overlay showSkipButton];

    XCTAssertTrue(overlay.closeButton.hidden);
    XCTAssertFalse(overlay.skipButton.hidden);
    XCTAssertNil(overlay.timerView);
}

- (void)testShowCountdownTimer {
    MPAdViewOverlay *overlay = [[MPAdViewOverlay alloc] init];

    [overlay delayForDuration:5 showCountdownTimer:YES countdownTimerDelay:0];

    XCTAssertTrue(overlay.closeButton.hidden);
    XCTAssertTrue(overlay.skipButton.hidden);
    XCTAssertNotNil(overlay.timerView);
    XCTAssertFalse(overlay.timerView.hidden);
}

- (void)testHideControls {
    MPAdViewOverlay *overlay = [[MPAdViewOverlay alloc] init];

    // Since there is no persistant timer, create one and make sure it's
    // set to nil after hiding controls.
    [overlay delayForDuration:5 showCountdownTimer:YES countdownTimerDelay:0];

    [overlay hideControls];

    XCTAssertTrue(overlay.closeButton.hidden);
    XCTAssertTrue(overlay.skipButton.hidden);
    XCTAssertNil(overlay.timerView);
}

#pragma mark - Countdown Timer

- (void)testCallbackAfterShowingCountdownTimer {
    XCTestExpectation *countdownExpectation = [self expectationWithDescription:@"did finish countdown"];

    MPAdViewOverlayDelegateMock *mockDelegate = [[MPAdViewOverlayDelegateMock alloc] init];
    mockDelegate.overlayDidFinishCountdownBlock = ^(MPAdViewOverlay *overlay) {
        [countdownExpectation fulfill];
    };

    MPAdViewOverlay *overlay = [[MPAdViewOverlay alloc] init];
    overlay.delegate = mockDelegate;

    [overlay delayForDuration:0.1 showCountdownTimer:YES countdownTimerDelay:0];

    XCTAssertNotNil(overlay.timerView);
    XCTAssertFalse(overlay.timerView.isHidden);

    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    // The timer view should still be visible.
    XCTAssertFalse(overlay.timerView.isHidden);
}

- (void)testCallbackAfterShowingDelayedCountdownTimer {
    XCTestExpectation *countdownExpectation = [self expectationWithDescription:@"did finish countdown"];

    MPAdViewOverlayDelegateMock *mockDelegate = [[MPAdViewOverlayDelegateMock alloc] init];
    mockDelegate.overlayDidFinishCountdownBlock = ^(MPAdViewOverlay *overlay) {
        [countdownExpectation fulfill];
    };

    MPAdViewOverlay *overlay = [[MPAdViewOverlay alloc] init];
    overlay.delegate = mockDelegate;

    [overlay delayForDuration:0.2 showCountdownTimer:YES countdownTimerDelay:0.1];

    XCTAssertNotNil(overlay.timerView);
    // The timer view should be hidden initially.
    XCTAssertTrue(overlay.timerView.isHidden);

    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    // The timer view should be shown.
    XCTAssertFalse(overlay.timerView.isHidden);
}

- (void)testCallbackAfterDelayingWithoutCountdownTimer {
    XCTestExpectation *countdownExpectation = [self expectationWithDescription:@"did finish countdown"];

    MPAdViewOverlayDelegateMock *mockDelegate = [[MPAdViewOverlayDelegateMock alloc] init];
    mockDelegate.overlayDidFinishCountdownBlock = ^(MPAdViewOverlay *overlay) {
        [countdownExpectation fulfill];
    };

    MPAdViewOverlay *overlay = [[MPAdViewOverlay alloc] init];
    overlay.delegate = mockDelegate;

    [overlay delayForDuration:0.1 showCountdownTimer:NO countdownTimerDelay:0];

    XCTAssertNotNil(overlay.timerView);
    XCTAssertTrue(overlay.timerView.isHidden);

    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    // The timer view should still be hidden.
    XCTAssertTrue(overlay.timerView.isHidden);
}

- (void)testSecondDelayWithExistingTimerDoesNotFireFirstTimer {
    // Create two expectations, one to make sure we fire once, and a second
    // to make sure we don't fire twice.
    XCTestExpectation *countdownExpectation = [self expectationWithDescription:@"did finish countdown"];

    XCTestExpectation *doesNotFireTwiceExpectation = [self expectationWithDescription:@"did finish countdown twice"];
    countdownExpectation.inverted = YES;
    countdownExpectation.expectedFulfillmentCount = 2;

    MPAdViewOverlayDelegateMock *mockDelegate = [[MPAdViewOverlayDelegateMock alloc] init];
    mockDelegate.overlayDidFinishCountdownBlock = ^(MPAdViewOverlay *overlay) {
        [countdownExpectation fulfill];
        [doesNotFireTwiceExpectation fulfill];
    };

    MPAdViewOverlay *overlay = [[MPAdViewOverlay alloc] init];
    overlay.delegate = mockDelegate;

    [overlay delayForDuration:0.2 showCountdownTimer:YES countdownTimerDelay:0];

    // Start a delay before the first delay has finished.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [overlay delayForDuration:0.2 showCountdownTimer:YES countdownTimerDelay:0];
    });

    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

#pragma mark - Pause/Resume

- (void)testPauseResume {
    MPAdViewOverlay *overlay = [[MPAdViewOverlay alloc] init];

    [overlay delayForDuration:10 showCountdownTimer:YES countdownTimerDelay:5];

    XCTAssertTrue(overlay.countdownDelayTimer.isCountdownActive);
    XCTAssertTrue(overlay.timerView.isCountdownActive);

    [overlay pause];

    XCTAssertFalse(overlay.countdownDelayTimer.isCountdownActive);
    XCTAssertFalse(overlay.timerView.isCountdownActive);

    [overlay resume];

    XCTAssertTrue(overlay.countdownDelayTimer.isCountdownActive);
    XCTAssertTrue(overlay.timerView.isCountdownActive);
}

#pragma mark - Clickthrough

- (void)testInitialClickthroughType {
    MPAdViewOverlay *overlay = [[MPAdViewOverlay alloc] init];
    XCTAssertEqual(overlay.clickthroughType, MPAdOverlayClickthroughTypePassthrough);
    XCTAssertFalse(overlay.clickThroughGestureRecognizer.enabled);
    XCTAssertTrue(overlay.callToActionButton.hidden);
}

- (void)testCTAClickthroughType {
    MPAdViewOverlay *overlay = [[MPAdViewOverlay alloc] init];
    overlay.clickthroughType = MPAdOverlayClickthroughTypeCallToAction;
    XCTAssertTrue(overlay.clickThroughGestureRecognizer.enabled);
    XCTAssertFalse(overlay.callToActionButton.hidden);
}

@end
