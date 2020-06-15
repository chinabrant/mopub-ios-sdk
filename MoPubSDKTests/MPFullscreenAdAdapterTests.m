//
//  MPFullscreenAdAdapterTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdAdapterDelegateMock.h"
#import "MPAdConfiguration.h"
#import "MPFullscreenAdAdapter+Testing.h"
#import "MPFullscreenAdAdapterMock.h"
#import "MPFullscreenAdViewController+Private.h"
#import "MPMockAdDestinationDisplayAgent.h"
#import "MPMockAnalyticsTracker.h"
#import "MPMockDiskLRUCache.h"
#import "MPFullscreenAdAdapterDelegateMock.h"
#import "MPMockVASTTracking.h"
#import "XCTestCase+MPAddition.h"

static const NSTimeInterval kDefaultTimeout = 10;

@interface MPFullscreenAdAdapterTests : XCTestCase

@property (nonatomic, strong) MPAdAdapterDelegateMock *adAdapterDelegateMock;
@property (nonatomic, strong) MPFullscreenAdAdapterDelegateMock *fullscreenAdAdapterDelegateMock;

@end

@implementation MPFullscreenAdAdapterTests

- (void)setUp {
    self.adAdapterDelegateMock = [MPAdAdapterDelegateMock new];
    self.fullscreenAdAdapterDelegateMock = [MPFullscreenAdAdapterDelegateMock new];
}

- (MPFullscreenAdAdapter *)createTestSubjectWithAdConfig:(MPAdConfiguration *)adConfig {
    MPFullscreenAdAdapter *adAdapter = [MPFullscreenAdAdapter new];
    adAdapter.adapterDelegate = self.adAdapterDelegateMock;
    adAdapter.delegate = self.fullscreenAdAdapterDelegateMock;
    adAdapter.adContentType = adConfig.adContentType;
    adAdapter.configuration = adConfig;
    adAdapter.configuration.selectedReward = [MPReward new];
    adAdapter.adDestinationDisplayAgent = [MPMockAdDestinationDisplayAgent new];
    adAdapter.mediaFileCache = [MPMockDiskLRUCache new];
    adAdapter.vastTracking = [MPMockVASTTracking new];
    return adAdapter;
}

- (MPFullscreenAdAdapter *)createTestSubject {
    // Populate MPX trackers coming back in the metadata field
    NSDictionary *headers = @{
        kAdTypeMetadataKey: kAdTypeInterstitial,
        kFullAdTypeMetadataKey: kAdTypeVAST,
        kVASTVideoTrackersMetadataKey: @"{\"events\":[\"start\",\"midpoint\",\"thirdQuartile\",\"companionAdClick\",\"firstQuartile\",\"companionAdView\",\"complete\"],\"urls\":[\"https://mpx.mopub.com/video_event?event_type=%%VIDEO_EVENT%%\"]}"
    };

    NSData *vastData = [self dataFromXMLFileNamed:@"VAST_3.0_linear_ad_comprehensive"];
    MPAdConfiguration *mockAdConfig = [[MPAdConfiguration alloc] initWithMetadata:headers data:vastData isFullscreenAd:YES];
    return [self createTestSubjectWithAdConfig:mockAdConfig];
}

/// Test no crash happens for invalid inputs.
- (void)testNoCrash {
    MPFullscreenAdAdapter *adAdapter = [self createTestSubject];

    // test passes if no crash: should not crash if valid ad config is not present
    [adAdapter requestAdWithAdapterInfo:@{} adMarkup:nil];

    // test passes if no crash: should not crash if root view controller is nil
    [adAdapter showFullscreenAdFromViewController:nil];
}

/// Test the custom adAdapter as an `MPVideoPlayerDelegate`.
- (void)testMPVideoPlayerDelegate {
    NSTimeInterval videoDuration = 30;
    NSError *mockError = [NSError errorWithDomain:@"mock" code:-1 userInfo:nil];
    MPAdContainerView *mockPlayerView = [MPAdContainerView new];
    MPVASTIndustryIconView *mockIndustryIconView = [MPVASTIndustryIconView new];
    MPVASTCompanionAdView *mockCompanionAdView = [MPVASTCompanionAdView new];

    MPFullscreenAdAdapter *adAdapter = [self createTestSubject];
    MPMockVASTTracking *mockVastTracking = (MPMockVASTTracking *)adAdapter.vastTracking;

    [adAdapter videoPlayerDidLoadVideo:mockPlayerView];
    XCTAssertEqual(1, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapterDidLoadAd:)]);

    [adAdapter videoPlayerDidFailToLoadVideo:mockPlayerView error:mockError];
    XCTAssertEqual(1, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapter:didFailToLoadAdWithError:)]);

    [self.fullscreenAdAdapterDelegateMock resetSelectorCounter];
    [mockVastTracking resetHistory];
    [adAdapter videoPlayerDidStartVideo:mockPlayerView duration:videoDuration];
    XCTAssertEqual(3, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]); // Start, CreativeView, and Impression
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventCreativeView]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventImpression]);

    [self.fullscreenAdAdapterDelegateMock resetSelectorCounter];
    [mockVastTracking resetHistory];
    [adAdapter videoPlayerDidCompleteVideo:mockPlayerView duration:videoDuration];
    XCTAssertEqual(1, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapter:willRewardUser:)]);
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventComplete]);

    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView videoDidReachProgressTime:videoDuration duration:videoDuration];
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(handleVideoProgressEvent:videoDuration:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventStart]);
    [adAdapter videoPlayer:mockPlayerView videoDidReachProgressTime:videoDuration * 0.25 duration:videoDuration];
    XCTAssertEqual(2, [mockVastTracking countOfSelectorCalls:@selector(handleVideoProgressEvent:videoDuration:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventFirstQuartile]);
    [adAdapter videoPlayer:mockPlayerView videoDidReachProgressTime:videoDuration * 5 duration:videoDuration];
    XCTAssertEqual(3, [mockVastTracking countOfSelectorCalls:@selector(handleVideoProgressEvent:videoDuration:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventMidpoint]);
    [adAdapter videoPlayer:mockPlayerView videoDidReachProgressTime:videoDuration * 0.75 duration:videoDuration];
    XCTAssertEqual(4, [mockVastTracking countOfSelectorCalls:@selector(handleVideoProgressEvent:videoDuration:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventThirdQuartile]);
    [mockVastTracking resetHistory];

    [self.fullscreenAdAdapterDelegateMock resetSelectorCounter];
    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView
                    didTriggerEvent:MPVideoPlayerEvent_ClickThrough
                      videoProgress:1];
    XCTAssertEqual(1, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapterDidReceiveTap:)]);
    XCTAssertEqual(0, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]); // 0 since URL is nil
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventClick]);

    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView
                    didTriggerEvent:MPVideoPlayerEvent_Close
                      videoProgress:2];
    XCTAssertEqual(2, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventClose]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventCloseLinear]);

    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView
                    didTriggerEvent:MPVideoPlayerEvent_Skip
                      videoProgress:3];
    XCTAssertEqual(3, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(stopViewabilityTracking)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventSkip]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventClose]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventCloseLinear]);
    [mockVastTracking resetHistory];

    [adAdapter videoPlayer:mockPlayerView didShowIndustryIconView:mockIndustryIconView];
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);

    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView didClickIndustryIconView:mockIndustryIconView overridingClickThroughURL:nil];
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);

    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView didShowCompanionAdView:mockCompanionAdView];
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);

    // Clicking on a companion with no clickthrough URL should not trigger events.
    [self.fullscreenAdAdapterDelegateMock resetSelectorCounter];
    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView didClickCompanionAdView:mockCompanionAdView overridingClickThroughURL:nil];
    XCTAssertEqual(0, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapterDidReceiveTap:)]);
    XCTAssertEqual(0, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);

    [adAdapter videoPlayer:mockPlayerView didFailToLoadCompanionAdView:mockCompanionAdView]; // pass if no crash
}

/// Test `customerId` comes from `MPFullscreenAdAdapter.adapterDelegate`
- (void)testCustomerId {
    MPFullscreenAdAdapter * adapter = [self createTestSubject];
    NSString * customerId = [adapter customerIdForAdapter:adapter];
    XCTAssertTrue([customerId isEqualToString:self.adAdapterDelegateMock.customerId]);
}

/// Test the custom adAdapter as an `MPRewardedVideoCustomEvent`.
- (void)testMPRewardedVideoCustomadAdapter {
    MPFullscreenAdAdapter *adAdapter = [self createTestSubject];
    XCTAssertTrue([adAdapter enableAutomaticImpressionAndClickTracking]);
    [adAdapter handleDidPlayAd]; // test passes if no crash
    [adAdapter handleDidInvalidateAd]; // test passes if no crash
    [adAdapter requestAdWithAdapterInfo:@{} adMarkup:nil]; // test passes if no crash
}

/// Test the custom adAdapter as an `MPFullscreenAdViewControllerAppearanceDelegate`.
- (void)testMPFullscreenAdViewControllerAppearanceDelegate {
    MPFullscreenAdAdapter *adAdapter = [self createTestSubject];
    MPFullscreenAdViewController *mockVC = [MPFullscreenAdViewController new];

    [adAdapter fullscreenAdWillAppear:mockVC];
    XCTAssertEqual(1, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapterAdWillAppear:)]);

    [adAdapter fullscreenAdDidAppear:mockVC];
    XCTAssertEqual(1, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapterAdDidAppear:)]);

    [adAdapter fullscreenAdWillDisappear:mockVC];
    XCTAssertEqual(1, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapterAdWillDisappear:)]);

    [adAdapter fullscreenAdDidDisappear:mockVC];
    XCTAssertEqual(1, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapterAdDidDisappear:)]);
}

#pragma mark - VAST Trackers

- (void)testVASTTrackersCombined {
    // VAST Tracking events to check
    NSArray<MPVideoEvent> *trackingEventNames = @[
        MPVideoEventComplete,
        MPVideoEventFirstQuartile,
        MPVideoEventMidpoint,
        MPVideoEventStart,
        MPVideoEventThirdQuartile
    ];

    // Configure the delegate
    MPFullscreenAdAdapterDelegateMock *mockDelegate = [MPFullscreenAdAdapterDelegateMock new];
    mockDelegate.adEventExpectation = [self expectationWithDescription:@"Wait for load"];

    NSDictionary *headers = @{
        kAdTypeMetadataKey: kAdTypeInterstitial,
        kFullAdTypeMetadataKey: kAdTypeVAST,
        kVASTVideoTrackersMetadataKey: @"{\"events\":[\"start\",\"midpoint\",\"thirdQuartile\",\"firstQuartile\",\"complete\"],\"urls\":[\"https://mpx.mopub.com/video_event?event_type=%%VIDEO_EVENT%%\"]}"
    };
    NSData *vastData = [self dataFromXMLFileNamed:@"VAST_3.0_linear_ad_comprehensive"];
    MPAdConfiguration *mockAdConfig = [[MPAdConfiguration alloc] initWithMetadata:headers data:vastData isFullscreenAd:YES];
    MPFullscreenAdAdapter *adAdapter = [self createTestSubjectWithAdConfig:mockAdConfig];
    adAdapter.delegate = mockDelegate; // the delegate needs a strong reference in current scope

    // Load the fake video ad
    [adAdapter fetchAndLoadVideoAd];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // Verify that the video configuration includes both the VAST XML video trackers and the MPX trackers
    MPVideoConfig *videoConfig = adAdapter.videoConfig;
    XCTAssertNotNil(videoConfig);

    for (MPVideoEvent eventName in trackingEventNames) {
        NSArray<MPVASTTrackingEvent *> *trackers = [videoConfig trackingEventsForKey:eventName];
        XCTAssert(trackers.count > 0);

        // Map the URLs into Strings
        NSMutableArray<NSString *> *trackerUrlStrings = [NSMutableArray array];
        [trackers enumerateObjectsUsingBlock:^(MPVASTTrackingEvent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [trackerUrlStrings addObject:obj.URL.absoluteString];
        }];

        // Expected MPX URL
        NSString *expectedUrl = [NSString stringWithFormat:@"https://mpx.mopub.com/video_event?event_type=%@", eventName];
        XCTAssert([trackerUrlStrings containsObject:expectedUrl], @"Trackers for %@ event did not contain %@", eventName, expectedUrl);

        // Expected VAST URL
        NSString *expectedEmbeddedUrl = [NSString stringWithFormat:@"https://www.mopub.com/?q=%@", eventName];
        XCTAssert([trackerUrlStrings containsObject:expectedEmbeddedUrl], @"Trackers for %@ event did not contain %@", eventName, expectedEmbeddedUrl);
    }
}

- (void)testVASTCompanionAdTrackersCombined {
    // VAST Tracking events to check
    NSArray<MPVideoEvent> *trackingEventNames = @[
        MPVideoEventCompanionAdClick,
        MPVideoEventCompanionAdView,
        MPVideoEventComplete,
        MPVideoEventFirstQuartile,
        MPVideoEventMidpoint,
        MPVideoEventStart,
        MPVideoEventThirdQuartile
    ];

    // Configure the delegate
    MPFullscreenAdAdapterDelegateMock *mockDelegate = [MPFullscreenAdAdapterDelegateMock new];
    mockDelegate.adEventExpectation = [self expectationWithDescription:@"Wait for load"];

    MPFullscreenAdAdapter *adAdapter = [self createTestSubject];
    adAdapter.delegate = mockDelegate; // the delegate needs a strong reference in current scope

    // Load the fake video ad
    [adAdapter fetchAndLoadVideoAd];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // Verify that the video configuration includes both the VAST XML video trackers and the MPX trackers
    MPVideoConfig *videoConfig = adAdapter.videoConfig;
    XCTAssertNotNil(videoConfig);

    // Verify that the ad configuration includes the MPX trackers
    NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> *vastVideoTrackers = adAdapter.configuration.vastVideoTrackers;
    XCTAssertNotNil(vastVideoTrackers);

    for (MPVideoEvent eventName in trackingEventNames) {
        NSArray<MPVASTTrackingEvent *> *trackers = vastVideoTrackers[eventName];
        XCTAssert(trackers.count > 0);

        // Map the URLs into Strings
        NSMutableArray<NSString *> *trackerUrlStrings = [NSMutableArray array];
        [trackers enumerateObjectsUsingBlock:^(MPVASTTrackingEvent * _Nonnull event, NSUInteger idx, BOOL * _Nonnull stop) {
            [trackerUrlStrings addObject:event.URL.absoluteString];
        }];

        // Expected MPX URL
        NSString *expectedUrl = [NSString stringWithFormat:@"https://mpx.mopub.com/video_event?event_type=%@", eventName];
        XCTAssert([trackerUrlStrings containsObject:expectedUrl], @"Trackers for %@ event did not contain %@", eventName, expectedUrl);
    }

    // Mocks
    MPMockVASTTracking *mockVastTracking = (MPMockVASTTracking *)adAdapter.vastTracking;
    MPAdContainerView *mockPlayerView = [MPAdContainerView new];
    MPVASTCompanionAdView *mockCompanionAdView = [MPVASTCompanionAdView new];

    // Trigger Companion Ad View event
    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView didShowCompanionAdView:mockCompanionAdView];

    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);
    XCTAssertNotNil(mockVastTracking.historyOfSentURLs);
    XCTAssert(mockVastTracking.historyOfSentURLs.count == 1);

    NSURL *expectedCompanionAdViewUrl = [NSURL URLWithString:@"https://mpx.mopub.com/video_event?event_type=companionAdView"];
    XCTAssert([mockVastTracking.historyOfSentURLs containsObject:expectedCompanionAdViewUrl]);

    // Clicking on a companion with no clickthrough URL should not trigger events.
    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView didClickCompanionAdView:mockCompanionAdView overridingClickThroughURL:nil];

    XCTAssertEqual(0, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);
    XCTAssertNotNil(mockVastTracking.historyOfSentURLs);
    XCTAssert(mockVastTracking.historyOfSentURLs.count == 0);
}

- (void)testClickTracking {
    MPMockAnalyticsTracker *trackerMock = [MPMockAnalyticsTracker new];
    MPFullscreenAdAdapterMock *adapter = [MPFullscreenAdAdapterMock new];
    adapter.configuration = [MPAdConfiguration new];
    adapter.analyticsTracker = trackerMock;

    // Test with `enableAutomaticImpressionAndClickTracking = YES`
    adapter.enableAutomaticImpressionAndClickTracking = YES;

    // No click has been tracked yet
    XCTAssertEqual(0, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);

    // More than one click track is prevented
    [adapter fullscreenAdAdapterDidTrackClick:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [adapter fullscreenAdAdapterDidTrackClick:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // `didReceiveTap` automatically counts as a click, but not more than once
    [adapter fullscreenAdAdapterDidReceiveTap:adapter];
    XCTAssertEqual(2, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [adapter fullscreenAdAdapterDidReceiveTap:adapter];
    XCTAssertEqual(2, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // Repeat the tests above with `enableAutomaticImpressionAndClickTracking = NO`
    [trackerMock reset];
    adapter.enableAutomaticImpressionAndClickTracking = NO;

    // No click has been tracked yet
    XCTAssertEqual(0, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);

    // More than one click track is prevented
    [adapter fullscreenAdAdapterDidTrackClick:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [adapter fullscreenAdAdapterDidTrackClick:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // `didReceiveTap` does not count as a click since `enableAutomaticImpressionAndClickTracking = NO`
    [adapter fullscreenAdAdapterDidReceiveTap:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [adapter fullscreenAdAdapterDidReceiveTap:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;
}

- (void)testImpressionTracking {
    MPMockAnalyticsTracker *trackerMock = [MPMockAnalyticsTracker new];
    MPFullscreenAdAdapterMock *adapter = [MPFullscreenAdAdapterMock new];
    adapter.configuration = [MPAdConfiguration new];
    adapter.analyticsTracker = trackerMock;

    // Test with `enableAutomaticImpressionAndClickTracking = YES`
    adapter.enableAutomaticImpressionAndClickTracking = YES;

    // Test no impression has been tracked yet
    XCTAssertEqual(0, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);

    // Test impressions are tracked, but not more than once
    [adapter fullscreenAdAdapterDidTrackImpression:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);
    [adapter fullscreenAdAdapterDidTrackImpression:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);
    adapter.hasTrackedImpression = NO;

    // Test impressions are automatically tracked from `viewDidAppear`, but not more than once
    [adapter fullscreenAdAdapterAdDidAppear:adapter];
    XCTAssertEqual(2, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);
    [adapter fullscreenAdAdapterAdDidAppear:adapter];
    XCTAssertEqual(2, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);
    adapter.hasTrackedImpression = NO;

    // Repeat the tests above with `enableAutomaticImpressionAndClickTracking = NO`
    [trackerMock reset];
    adapter.enableAutomaticImpressionAndClickTracking = NO;

    // Test no impression has been tracked yet
    XCTAssertEqual(0, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);

    // Test impressions are tracked, but not more than once
    [adapter fullscreenAdAdapterDidTrackImpression:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);
    [adapter fullscreenAdAdapterDidTrackImpression:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);
    adapter.hasTrackedImpression = NO;

    // Test impressions are NOT tracked from `viewDidAppear` since `enableAutomaticImpressionAndClickTracking = NO`
    [adapter fullscreenAdAdapterAdDidAppear:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);
    [adapter fullscreenAdAdapterAdDidAppear:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);
    adapter.hasTrackedImpression = NO;
}

@end