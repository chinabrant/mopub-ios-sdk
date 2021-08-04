//
//  MPAdContainerViewTests.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdContainerView.h"
#import "MPAdContainerView+Private.h"
#import "MPAdContainerView+Testing.h"
#import "MPAdViewOverlayMock.h"
#import "MPAdViewOverlay+Private.h"
#import "MPVideoPlayerViewMock.h"
#import "MPAdContainerViewMock.h"
#import "MPVASTCompanionAdViewMock.h"
#import "MPAdContainerViewDelegateMock.h"
#import "XCTestCase+MPAddition.h"
#import "MoPubSDKTests-Swift.h"

// For non-module targets, UIKit must be explicitly imported
// since MoPubSDK-Swift.h will not import it.
#if __has_include(<MoPubSDK/MoPubSDK-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <MoPubSDK/MoPubSDK-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "MoPubSDK-Swift.h"
#endif

@interface MPAdContainerViewTests : XCTestCase
@end

@implementation MPAdContainerViewTests

#pragma mark - Ad Experience

- (void)testStartAdExperience {
    MPAdContainerView *container = [[MPAdContainerView alloc] init];

    [container startAdExperience];

    // This will immediately be finished as there is no countdown.
    XCTAssertEqual(container.adExperienceState, MPAdExperienceStateFinished);
    XCTAssertTrue(container.elapsedAdTimeStopwatch.isRunning);
    XCTAssertEqual(container.adIndex, 0);
}

- (void)testStartFinishAdExperience {
    MPAdContainerViewMock *container = [[MPAdContainerViewMock alloc] init];
    container.mockCountdownTime = 0.1;

    [container startAdExperience];
    XCTAssertEqual(container.adExperienceState, MPAdExperienceStateStarted);

    [container adViewOverlayDidFinishCountdown:container.overlay];
    XCTAssertEqual(container.adExperienceState, MPAdExperienceStateFinished);
}

- (void)testStartAdExperienceLatches {
    MPAdContainerViewMock *container = [[MPAdContainerViewMock alloc] init];
    container.mockCountdownTime = 0.1;

    [container startAdExperience];

    container.adIndex = 1;

    XCTAssertEqual(container.adExperienceState, MPAdExperienceStateStarted);

    // Calling startAdExperience a second time should do nothing, we should
    // still have the same ad index.
    [container startAdExperience];
    XCTAssertEqual(container.adIndex, 1);

    [container adViewOverlayDidFinishCountdown:container.overlay];
    XCTAssertEqual(container.adExperienceState, MPAdExperienceStateFinished);

    // Calling startAdExperience after the ad experience is finished should
    // not do anything.
    [container startAdExperience];
    XCTAssertEqual(container.adExperienceState, MPAdExperienceStateFinished);
    XCTAssertEqual(container.adIndex, 1);
}

- (void)testPlayVideoCallsStartAdExperience {
    MPVideoPlayerViewMock *mockVideoPlayer = [[MPVideoPlayerViewMock alloc] init];

    MPAdContainerView *container = [[MPAdContainerView alloc] init];
    container.videoPlayerView = mockVideoPlayer;

    [container playVideo];

    XCTAssertTrue(mockVideoPlayer.isVideoPlaying);
    XCTAssertFalse(mockVideoPlayer.isPaused);
    XCTAssertEqual(container.adExperienceState, MPAdExperienceStateFinished);
    XCTAssertTrue(container.elapsedAdTimeStopwatch.isRunning);
    XCTAssertEqual(container.adIndex, 0);
}

- (void)testInitialSkipTriggersAdExperienceDidFinish {
    __block NSUInteger didFinishAdExperienceCount = 0;
    MPAdContainerViewDelegateMock *mockDelegate = [[MPAdContainerViewDelegateMock alloc] init];
    mockDelegate.containerDidFinishAdExperience = ^(MPAdContainerView *container) {
        didFinishAdExperienceCount += 1;
    };

    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_no_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerView *container = [[MPAdContainerView alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];
    container.delegate = mockDelegate;

    [container playVideo];

    // Since the skip button is shown initially, this shouldn't be called yet.
    XCTAssertEqual(didFinishAdExperienceCount, 0);

    [container adViewOverlay:container.overlay didTriggerEvent:MPVideoEventSkip];

    // This should now be called after skipping.
    XCTAssertEqual(didFinishAdExperienceCount, 1);

    // This should not trigger another callback.
    [container adViewOverlay:container.overlay didTriggerEvent:MPVideoEventSkip];
    XCTAssertEqual(didFinishAdExperienceCount, 1);
}

- (void)testCountdownTimerThenSkipTriggersAdExperienceDidFinish {
    __block NSUInteger didFinishAdExperienceCount = 0;
    MPAdContainerViewDelegateMock *mockDelegate = [[MPAdContainerViewDelegateMock alloc] init];
    mockDelegate.containerDidFinishAdExperience = ^(MPAdContainerView *container) {
        didFinishAdExperienceCount += 1;
    };

    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_no_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerViewMock *container = [[MPAdContainerViewMock alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];
    container.delegate = mockDelegate;
    container.mockCountdownTime = 0.1;

    [container playVideo];
    XCTAssertEqual(didFinishAdExperienceCount, 0);

    [container adViewOverlayDidFinishCountdown:container.overlay];
    XCTAssertEqual(didFinishAdExperienceCount, 0);

    [container adViewOverlay:container.overlay didTriggerEvent:MPVideoEventSkip];
    XCTAssertEqual(didFinishAdExperienceCount, 1);

    // This should not trigger another callback.
    [container adViewOverlay:container.overlay didTriggerEvent:MPVideoEventSkip];
    XCTAssertEqual(didFinishAdExperienceCount, 1);
}

- (void)testVideoCompletionTriggersAdExperienceDidFinish {
    __block NSUInteger didFinishAdExperienceCount = 0;
    MPAdContainerViewDelegateMock *mockDelegate = [[MPAdContainerViewDelegateMock alloc] init];
    mockDelegate.containerDidFinishAdExperience = ^(MPAdContainerView *container) {
        didFinishAdExperienceCount += 1;
    };

    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_no_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerViewMock *container = [[MPAdContainerViewMock alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];
    container.delegate = mockDelegate;
    container.mockCountdownTime = 0.1;

    [container playVideo];
    XCTAssertEqual(didFinishAdExperienceCount, 0);

    [container videoPlayerViewDidCompleteVideo:container.videoPlayerView duration:0];
    XCTAssertEqual(didFinishAdExperienceCount, 1);

    // This should not trigger another callback.
    [container videoPlayerViewDidCompleteVideo:container.videoPlayerView duration:0];
    XCTAssertEqual(didFinishAdExperienceCount, 1);
}

- (void)testEndCardTriggersAdExperienceDidFinish {
    __block NSUInteger didFinishAdExperienceCount = 0;
    MPAdContainerViewDelegateMock *mockDelegate = [[MPAdContainerViewDelegateMock alloc] init];
    mockDelegate.containerDidFinishAdExperience = ^(MPAdContainerView *container) {
        didFinishAdExperienceCount += 1;
    };

    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_image_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerView *container = [[MPAdContainerView alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];
    container.delegate = mockDelegate;

    [container playVideo];
    XCTAssertEqual(didFinishAdExperienceCount, 0);

    [container adViewOverlay:container.overlay didTriggerEvent:MPVideoEventSkip];
    XCTAssertEqual(didFinishAdExperienceCount, 1);

    // This should not trigger another callback.
    [container adViewOverlay:container.overlay didTriggerEvent:MPVideoEventSkip];
    XCTAssertEqual(didFinishAdExperienceCount, 1);
}

- (void)testEndCardWithCountdownTimerTriggersAdExperienceDidFinish {
    __block NSUInteger didFinishAdExperienceCount = 0;
    MPAdContainerViewDelegateMock *mockDelegate = [[MPAdContainerViewDelegateMock alloc] init];
    mockDelegate.containerDidFinishAdExperience = ^(MPAdContainerView *container) {
        didFinishAdExperienceCount += 1;
    };

    MPVASTCompanionAdViewMock *mockCompaionAdView = [[MPVASTCompanionAdViewMock alloc] init];
    mockCompaionAdView.mockIsLoaded = YES;
    // The companion ad must be hidden in order to be shown in nextAd;
    mockCompaionAdView.hidden = YES;

    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_image_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerViewMock *container = [[MPAdContainerViewMock alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];
    container.delegate = mockDelegate;
    container.companionAdView = mockCompaionAdView;

    [container playVideo];
    XCTAssertEqual(didFinishAdExperienceCount, 0);

    // Set the mock countdown for just the end card.
    container.mockCountdownTime = 0.1;
    [container adViewOverlay:container.overlay didTriggerEvent:MPVideoEventSkip];
    XCTAssertEqual(didFinishAdExperienceCount, 0);

    [container adViewOverlayDidFinishCountdown:container.overlay];
    XCTAssertEqual(didFinishAdExperienceCount, 1);

    // This should not trigger another callback.
    [container adViewOverlayDidFinishCountdown:container.overlay];
    XCTAssertEqual(didFinishAdExperienceCount, 1);
}

- (void)testNonVideoAdWithoutCountdownTimerTriggersAdExperienceDidFinish {
    __block NSUInteger didFinishAdExperienceCount = 0;
    MPAdContainerViewDelegateMock *mockDelegate = [[MPAdContainerViewDelegateMock alloc] init];
    mockDelegate.containerDidFinishAdExperience = ^(MPAdContainerView *container) {
        didFinishAdExperienceCount += 1;
    };

    MPAdContainerViewMock *container = [[MPAdContainerViewMock alloc] init];
    container.delegate = mockDelegate;

    [container startAdExperience];
    XCTAssertEqual(didFinishAdExperienceCount, 1);
}

- (void)testNonVideoAdWithCountdownTimerTriggersAdExperienceDidFinish {
    __block NSUInteger didFinishAdExperienceCount = 0;
    MPAdContainerViewDelegateMock *mockDelegate = [[MPAdContainerViewDelegateMock alloc] init];
    mockDelegate.containerDidFinishAdExperience = ^(MPAdContainerView *container) {
        didFinishAdExperienceCount += 1;
    };

    MPAdContainerViewMock *container = [[MPAdContainerViewMock alloc] init];
    container.delegate = mockDelegate;
    container.mockCountdownTime = 0.1;

    [container startAdExperience];
    XCTAssertEqual(didFinishAdExperienceCount, 0);

    [container adViewOverlayDidFinishCountdown:container.overlay];
    XCTAssertEqual(didFinishAdExperienceCount, 1);

    // This should not trigger another callback.
    [container adViewOverlayDidFinishCountdown:container.overlay];
    XCTAssertEqual(didFinishAdExperienceCount, 1);
}


#pragma mark - Clickthrough

- (void)testCorrectClickthroughMode {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_image_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerView *container = [[MPAdContainerView alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];

    XCTAssertEqual(container.overlay.clickthroughType, MPAdOverlayClickthroughTypeCallToAction);
    XCTAssertFalse(container.overlay.callToActionButton.isHidden);
    XCTAssertTrue([container.overlay.callToActionButtonTitle isEqualToString:@"Install Now"]);
}

- (void)testNoClickthrough {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_no_video_clickthrough"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerView *container = [[MPAdContainerView alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];

    XCTAssertEqual(container.overlay.clickthroughType, MPAdOverlayClickthroughTypeNone);
    XCTAssertTrue(container.overlay.callToActionButton.isHidden);
    XCTAssertNil(container.overlay.callToActionButtonTitle);
}

#pragma mark - Controls

- (void)testVideoInitialControlIsSkip {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_image_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerView *container = [[MPAdContainerView alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];

    // The initial control should be a skip button since there is no
    // countdown duration, but there is an end card.
    [container playVideo];
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateSkipButton);
}

- (void)testVideoInitialControlIsCountdown {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_no_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerViewMock *container = [[MPAdContainerViewMock alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];
    container.mockCountdownTime = 0.1;

    [container playVideo];
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateCountdown);
}

- (void)testVideoCountdownFinishedTriggersSkipButton {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_image_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerViewMock *container = [[MPAdContainerViewMock alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];
    container.mockCountdownTime = 0.1;

    [container playVideo];
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateCountdown);

    // Once the countdown finishes, the skip button should be shown since
    // there is an end card.
    [container adViewOverlayDidFinishCountdown:container.overlay];
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateSkipButton);
}

- (void)testVideoSkipNoEndCardTriggersCloseButton {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_no_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerView *container = [[MPAdContainerView alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];

    [container playVideo];
    XCTAssertEqual(container.adIndex, 0);

    [container adViewOverlay:container.overlay didTriggerEvent:MPVideoEventSkip];
    XCTAssertEqual(container.adIndex, 1);
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateCloseButton);

    // An additional call to skip should do nothing.
    [container adViewOverlay:container.overlay didTriggerEvent:MPVideoEventSkip];
    XCTAssertEqual(container.adIndex, 1);
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateCloseButton);
}

- (void)testVideoSkipWithEndCardTriggersNextAd {
    MPVASTCompanionAdViewMock *mockCompaionAdView = [[MPVASTCompanionAdViewMock alloc] init];
    mockCompaionAdView.mockIsLoaded = YES;
    // The companion ad must be hidden in order to be shown in nextAd;
    mockCompaionAdView.hidden = YES;

    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_image_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerView *container = [[MPAdContainerView alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];
    container.companionAdView = mockCompaionAdView;

    [container playVideo];
    XCTAssertEqual(container.adIndex, 0);

    [container adViewOverlay:container.overlay didTriggerEvent:MPVideoEventSkip];
    XCTAssertEqual(container.adIndex, 1);
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateCloseButton);

    // An additional skip should do nothing.
    [container adViewOverlay:container.overlay didTriggerEvent:MPVideoEventSkip];
    XCTAssertEqual(container.adIndex, 1);
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateCloseButton);
}

- (void)testVideoWithoutEndCardCompleteTriggersCloseButton {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_no_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerView *container = [[MPAdContainerView alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];

    [container playVideo];
    XCTAssertEqual(container.adIndex, 0);

    [container videoPlayerViewDidCompleteVideo:container.videoPlayerView duration:0];
    XCTAssertEqual(container.adIndex, 1);
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateCloseButton);

    // An additional video complete call should do nothing.
    [container videoPlayerViewDidCompleteVideo:container.videoPlayerView duration:0];
    XCTAssertEqual(container.adIndex, 1);
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateCloseButton);
}

- (void)testVideoCompleteWithEndCardTriggersNextAd {
    MPVASTCompanionAdViewMock *mockCompaionAdView = [[MPVASTCompanionAdViewMock alloc] init];
    mockCompaionAdView.mockIsLoaded = YES;
    // The companion ad must be hidden in order to be shown in nextAd;
    mockCompaionAdView.hidden = YES;

    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_image_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerView *container = [[MPAdContainerView alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];
    container.companionAdView = mockCompaionAdView;

    [container playVideo];
    XCTAssertEqual(container.adIndex, 0);

    [container videoPlayerViewDidCompleteVideo:container.videoPlayerView duration:0];
    XCTAssertEqual(container.adIndex, 1);
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateCloseButton);

    // An additional video complete call should do nothing.
    [container videoPlayerViewDidCompleteVideo:container.videoPlayerView duration:0];
    XCTAssertEqual(container.adIndex, 1);
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateCloseButton);
}

- (void)testVideoEndCardWithCountdownTimer {
    MPVASTCompanionAdViewMock *mockCompaionAdView = [[MPVASTCompanionAdViewMock alloc] init];
    mockCompaionAdView.mockIsLoaded = YES;
    // The companion ad must be hidden in order to be shown in nextAd;
    mockCompaionAdView.hidden = YES;

    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_image_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerViewMock *container = [[MPAdContainerViewMock alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];
    container.companionAdView = mockCompaionAdView;
    container.mockCountdownTime = 0.1;

    [container playVideo];
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateCountdown);

    [container adViewOverlayDidFinishCountdown:container.overlay];
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateSkipButton);

    [container adViewOverlay:container.overlay didTriggerEvent:MPVideoEventSkip];
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateCountdown);

    [container adViewOverlayDidFinishCountdown:container.overlay];
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateCloseButton);
}

- (void)testNonVideoInitialControlIsClose {
    MPImageCreativeView *imageView = [[MPImageCreativeView alloc] init];
    MPAdContainerViewMock *container = [[MPAdContainerViewMock alloc] initWithFrame:CGRectZero imageCreativeView:imageView];

    // The initial control should be a close button since there is no
    // countdown duration.
    [container startAdExperience];
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateCloseButton);
}

- (void)testNonVideoInitialControlIsCountdown {
    MPImageCreativeView *imageView = [[MPImageCreativeView alloc] init];
    MPAdContainerViewMock *container = [[MPAdContainerViewMock alloc] initWithFrame:CGRectZero imageCreativeView:imageView];
    container.mockCountdownTime = 0.1;

    [container startAdExperience];
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateCountdown);
}

- (void)testNonVideoCountdownFinishedTriggersCloseButton {
    MPImageCreativeView *imageView = [[MPImageCreativeView alloc] init];
    MPAdContainerViewMock *container = [[MPAdContainerViewMock alloc] initWithFrame:CGRectZero imageCreativeView:imageView];
    container.mockCountdownTime = 0.1;

    [container startAdExperience];
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateCountdown);

    [container adViewOverlayDidFinishCountdown:container.overlay];
    XCTAssertEqual(container.overlay.controlState, MPAdOverlayControlStateCloseButton);
}

#pragma mark - End Card

- (void)testUpdatesOverlayWhenShowingEndCard {
    MPVASTCompanionAdViewMock *mockCompaionAdView = [[MPVASTCompanionAdViewMock alloc] init];
    mockCompaionAdView.mockIsLoaded = YES;
    // The companion ad must be hidden in order to be shown in showCompaionAd.
    mockCompaionAdView.hidden = YES;

    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_image_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerView *container = [[MPAdContainerView alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];
    container.companionAdView = mockCompaionAdView;

    XCTAssertEqual(container.overlay.clickthroughType, MPAdOverlayClickthroughTypeCallToAction);

    [container adViewOverlay:container.overlay didTriggerEvent:MPVideoEventSkip];

    // The clickthrough type should change when showing the companion ad.
    XCTAssertEqual(container.overlay.clickthroughType, MPAdOverlayClickthroughTypePassthrough);
}

#pragma mark - Pause/Resume

- (void)testPauseResume {
    MPAdViewOverlayMock *mockOverlay = [[MPAdViewOverlayMock alloc] init];
    MPVideoPlayerViewMock *mockVideoPlayer = [[MPVideoPlayerViewMock alloc] init];

    MPAdContainerView *container = [[MPAdContainerView alloc] init];
    container.overlay = mockOverlay;
    container.videoPlayerView = mockVideoPlayer;

    [container playVideo];

    XCTAssertFalse(mockOverlay.isPaused);
    XCTAssertFalse(mockVideoPlayer.isPaused);
    XCTAssertTrue(container.elapsedAdTimeStopwatch.isRunning);

    [container pauseVideo];

    XCTAssertTrue(mockOverlay.isPaused);
    XCTAssertTrue(mockVideoPlayer.isPaused);
    XCTAssertFalse(container.elapsedAdTimeStopwatch.isRunning);

    [container resume];

    XCTAssertFalse(mockOverlay.isPaused);
    XCTAssertFalse(mockVideoPlayer.isPaused);
    XCTAssertTrue(container.elapsedAdTimeStopwatch.isRunning);
}

- (void)testPlayVideoAfterPauseDoesNotResume {
    MPAdViewOverlayMock *mockOverlay = [[MPAdViewOverlayMock alloc] init];
    MPVideoPlayerViewMock *mockVideoPlayer = [[MPVideoPlayerViewMock alloc] init];

    MPAdContainerView *container = [[MPAdContainerView alloc] init];
    container.overlay = mockOverlay;
    container.videoPlayerView = mockVideoPlayer;

    [container playVideo];

    XCTAssertFalse(mockOverlay.isPaused);
    XCTAssertFalse(mockVideoPlayer.isPaused);
    XCTAssertTrue(container.elapsedAdTimeStopwatch.isRunning);

    [container pauseVideo];

    XCTAssertTrue(mockOverlay.isPaused);
    XCTAssertTrue(mockVideoPlayer.isPaused);
    XCTAssertFalse(container.elapsedAdTimeStopwatch.isRunning);

    // playVideo is latched and should not resume the timers.
    [container playVideo];

    XCTAssertTrue(mockOverlay.isPaused);
    XCTAssertTrue(mockVideoPlayer.isPaused);
    XCTAssertFalse(container.elapsedAdTimeStopwatch.isRunning);
}

- (void)testPauseResumeAfterVideoSkipDoesNotResumeVideo {
    MPAdViewOverlayMock *mockOverlay = [[MPAdViewOverlayMock alloc] init];
    MPVideoPlayerViewMock *mockVideoPlayer = [[MPVideoPlayerViewMock alloc] init];

    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_no_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerView *container = [[MPAdContainerView alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];
    container.overlay = mockOverlay;
    container.videoPlayerView = mockVideoPlayer;

    [container playVideo];

    XCTAssertFalse(mockOverlay.isPaused);
    XCTAssertFalse(mockVideoPlayer.isPaused);
    XCTAssertTrue(container.elapsedAdTimeStopwatch.isRunning);

    // Once the user skips and the blurred last frame is shown, the video
    // player should be paused.
    [container adViewOverlay:container.overlay didTriggerEvent:MPVideoEventSkip];
    XCTAssertTrue(container.isVideoFinished);
    XCTAssertTrue(mockVideoPlayer.isPaused);

    [container pauseVideo];
    XCTAssertTrue(mockVideoPlayer.isPaused);

    // Resuming should not resume the video at this point.
    [container resume];
    XCTAssertTrue(mockVideoPlayer.isPaused);
}

- (void)testPauseResumeAfterVideoCompleteDoesNotResumeVideo {
    MPAdViewOverlayMock *mockOverlay = [[MPAdViewOverlayMock alloc] init];
    MPVideoPlayerViewMock *mockVideoPlayer = [[MPVideoPlayerViewMock alloc] init];

    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_no_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerView *container = [[MPAdContainerView alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];
    container.overlay = mockOverlay;
    container.videoPlayerView = mockVideoPlayer;

    [container playVideo];

    XCTAssertFalse(mockOverlay.isPaused);
    XCTAssertFalse(mockVideoPlayer.isPaused);
    XCTAssertTrue(container.elapsedAdTimeStopwatch.isRunning);

    // Once the video finishes, the blurred last frame is shown, but the
    // video is technically not paused.
    [container videoPlayerViewDidCompleteVideo:mockVideoPlayer duration:0];
    XCTAssertTrue(container.isVideoFinished);
    XCTAssertFalse(mockVideoPlayer.isPaused);

    // Pausing will pause the video.
    [container pauseVideo];
    XCTAssertTrue(mockVideoPlayer.isPaused);

    // But resuming should not call playVideo, since the video completed.
    [container resume];
    XCTAssertTrue(mockVideoPlayer.isPaused);
}

- (void)testSkipWithEndCardStopsVideo {
    MPVASTCompanionAdViewMock *mockCompaionAdView = [[MPVASTCompanionAdViewMock alloc] init];
    mockCompaionAdView.mockIsLoaded = YES;
    // The companion ad must be hidden in order to be shown in showCompaionAd.
    mockCompaionAdView.hidden = YES;

    MPAdViewOverlayMock *mockOverlay = [[MPAdViewOverlayMock alloc] init];
    MPVideoPlayerViewMock *mockVideoPlayer = [[MPVideoPlayerViewMock alloc] init];

    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_image_endcard"];
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPAdContainerView *container = [[MPAdContainerView alloc] initWithVideoURL:[NSURL URLWithString:@"test.com"] videoConfig:config];
    container.overlay = mockOverlay;
    container.companionAdView = mockCompaionAdView;
    container.videoPlayerView = mockVideoPlayer;

    [container playVideo];

    // Skipping to the end card should stop the video playback.
    [container adViewOverlay:container.overlay didTriggerEvent:MPVideoEventSkip];
    XCTAssertTrue(mockVideoPlayer.didCallStop);
}

@end
