//
//  MPFullscreenAdViewControllerTests.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPFullscreenAdViewController+MRAIDWeb.h"
#import "MPFullscreenAdViewController+Private.h"
#import "MPFullscreenAdViewController+Web.h"
#import "MPFullscreenAdAdapter+Private.h"
#import "MPFullscreenAdAdapter+Video.h"
#import "MPFullscreenAdViewControllerDelegateMock.h"
#import "MPProxy.h"
#import "MPAdContainerViewMock.h"

static NSTimeInterval const kTestTimeout = 3;

/**
 Test agains the @c MRAIDWeb category of @c MPFullscreenAdViewController.
 */
@interface MPFullscreenAdViewControllerTests : XCTestCase

@property (nonatomic, strong) MPFullscreenAdViewControllerDelegateMock *delegateMock;
@property (nonatomic, strong) MPProxy *mockProxy;

@end

@implementation MPFullscreenAdViewControllerTests

- (void)setUp {
    [super setUp];

    self.mockProxy = [[MPProxy alloc] initWithTarget:[MPFullscreenAdViewControllerDelegateMock new]];
    self.delegateMock = (MPFullscreenAdViewControllerDelegateMock *)self.mockProxy;
}

- (void)tearDown {
    [super tearDown];

    self.mockProxy = nil;
    self.delegateMock = nil;
}

/**
 Test the API in MPFullscreenAdViewController+MRAIDWeb.h.
 */
- (void)testMRAIDWebAPI {
    MPFullscreenAdViewController *viewController = [MPFullscreenAdViewController new];
    viewController.appearanceDelegate = self.delegateMock;
    viewController.webAdDelegate = self.delegateMock;

    XCTAssertNil(viewController.mraidController);
    [viewController loadConfigurationForMRAIDAd:[[MPAdConfiguration alloc] initWithMetadata:@{} data:nil isFullscreenAd:YES isRewarded:NO]];
    XCTAssertNotNil(viewController.mraidController);

    // Force type
    viewController.adContentType = MPAdContentTypeWebWithMRAID;

    // viewWillAppear:
    XCTestExpectation *willAppearExpectation = [self expectationWithDescription:@"view will appear"];
    [self.mockProxy registerSelector:@selector(fullscreenAdWillAppear:) forPostAction:^(NSInvocation *invocation) {
        [willAppearExpectation fulfill];
    }];
    [viewController viewWillAppear:YES];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // viewDidAppear:
    XCTestExpectation *didAppearExpectation = [self expectationWithDescription:@"view did appear"];
    [self.mockProxy registerSelector:@selector(fullscreenAdDidAppear:) forPostAction:^(NSInvocation *invocation) {
        [didAppearExpectation fulfill];
    }];
    [viewController viewDidAppear:YES];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // viewWillDisappear:
    XCTestExpectation *willDisappearExpectation = [self expectationWithDescription:@"view will disappear"];
    [self.mockProxy registerSelector:@selector(fullscreenAdWillDisappear:) forPostAction:^(NSInvocation *invocation) {
        [willDisappearExpectation fulfill];
    }];
    [viewController viewWillDisappear:YES];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // viewDidDisappear:
    XCTestExpectation *didDisappearExpectation = [self expectationWithDescription:@"view did disappear"];
    [self.mockProxy registerSelector:@selector(fullscreenAdDidDisappear:) forPostAction:^(NSInvocation *invocation) {
        [didDisappearExpectation fulfill];
    }];
    [viewController viewDidDisappear:YES];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

/**
 Test the API in MPFullscreenAdViewController+Web.h.
 */
- (void)testWebAPI {
    MPFullscreenAdViewController *viewController = [MPFullscreenAdViewController new];
    viewController.appearanceDelegate = self.delegateMock;
    viewController.webAdDelegate = self.delegateMock;

    XCTAssertNil(viewController.mraidController);
    [viewController loadConfigurationForMRAIDAd:[[MPAdConfiguration alloc] initWithMetadata:@{} data:nil isFullscreenAd:YES isRewarded:NO]];
    XCTAssertNotNil(viewController.mraidController);

    // Force type
    viewController.adContentType = MPAdContentTypeWebNoMRAID;

    // viewWillAppear:
    XCTestExpectation *willAppearExpectation = [self expectationWithDescription:@"view will appear"];
    [self.mockProxy registerSelector:@selector(fullscreenAdWillAppear:) forPostAction:^(NSInvocation *invocation) {
        [willAppearExpectation fulfill];
    }];
    [viewController viewWillAppear:YES];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // viewDidAppear:
    XCTestExpectation *didAppearExpectation = [self expectationWithDescription:@"view did appear"];
    [self.mockProxy registerSelector:@selector(fullscreenAdDidAppear:) forPostAction:^(NSInvocation *invocation) {
        [didAppearExpectation fulfill];
    }];
    [viewController viewDidAppear:YES];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // viewWillDisappear:
    XCTestExpectation *willDisappearExpectation = [self expectationWithDescription:@"view will disappear"];
    [self.mockProxy registerSelector:@selector(fullscreenAdWillDisappear:) forPostAction:^(NSInvocation *invocation) {
        [willDisappearExpectation fulfill];
    }];
    [viewController viewWillDisappear:YES];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // viewDidDisappear:
    XCTestExpectation *didDisappearExpectation = [self expectationWithDescription:@"view did disappear"];
    [self.mockProxy registerSelector:@selector(fullscreenAdDidDisappear:) forPostAction:^(NSInvocation *invocation) {
        [didDisappearExpectation fulfill];
    }];
    [viewController viewDidDisappear:YES];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

#pragma mark - Interruptions

- (void)testWebClickthroughPauses {
    MPFullscreenAdViewController *viewController = [MPFullscreenAdViewController new];

    MPAdContainerViewMock *mockContainerView = [MPAdContainerViewMock new];
    viewController.adContainerView = mockContainerView;

    [viewController fullscreenWebAdWillDisappear];
    XCTAssertTrue(mockContainerView.isPaused);

    [viewController fullscreenWebAdWillAppear];
    XCTAssertFalse(mockContainerView.isPaused);
}

- (void)testMRAIDClickthroughPauses {
    MPFullscreenAdViewController *viewController = [MPFullscreenAdViewController new];

    MPAdContainerViewMock *mockContainerView = [MPAdContainerViewMock new];
    viewController.adContainerView = mockContainerView;

    [viewController fullscreenMRAIDWebAdWillDisappear];
    XCTAssertTrue(mockContainerView.isPaused);

    [viewController fullscreenMRAIDWebAdWillAppear];
    XCTAssertFalse(mockContainerView.isPaused);
}

- (void)testVASTClickthroughPauses {
    MPFullscreenAdAdapter *adapter = [[MPFullscreenAdAdapter alloc] init];
    MPFullscreenAdViewController *viewController = [MPFullscreenAdViewController new];
    adapter.viewController = viewController;

    MPAdContainerViewMock *mockContainerView = [MPAdContainerViewMock new];
    viewController.adContainerView = mockContainerView;

    [adapter displayAgentWillPresentModal];
    XCTAssertTrue(mockContainerView.isPaused);

    [adapter displayAgentDidDismissModal];
    XCTAssertFalse(mockContainerView.isPaused);
}

- (void)testAudioInterruptionPauses {
    MPFullscreenAdAdapter *adapter = [[MPFullscreenAdAdapter alloc] init];
    MPFullscreenAdViewController *viewController = [MPFullscreenAdViewController new];
    adapter.viewController = viewController;

    MPAdContainerViewMock *mockContainerView = [MPAdContainerViewMock new];
    viewController.adContainerView = mockContainerView;

    MPVideoPlayerView *mockPlayer = [[MPVideoPlayerView alloc] init];
    [adapter videoPlayerAudioInterruptionDidBegin:mockPlayer];
    XCTAssertTrue(mockContainerView.isPaused);

    [adapter videoPlayerAudioInterruptionDidEnd:mockPlayer];
    XCTAssertFalse(mockContainerView.isPaused);
}

- (void)testBackgroundingAppPauses {
    MPFullscreenAdViewController *viewController = [MPFullscreenAdViewController new];

    MPAdContainerViewMock *mockContainerView = [MPAdContainerViewMock new];
    viewController.adContainerView = mockContainerView;

    NSNotification *mockNotification = [[NSNotification alloc] initWithName:@"mockNotification" object:nil userInfo:nil];
    [viewController appDidEnterBackground:mockNotification];
    XCTAssertTrue(mockContainerView.isPaused);

    [viewController appWillEnterForeground:mockNotification];
    XCTAssertFalse(mockContainerView.isPaused);
}

- (void)testMultipleInterruptions {
    MPFullscreenAdViewController *viewController = [MPFullscreenAdViewController new];

    MPAdContainerViewMock *mockContainerView = [MPAdContainerViewMock new];
    viewController.adContainerView = mockContainerView;

    NSNotification *mockNotification = [[NSNotification alloc] initWithName:@"mockNotification" object:nil userInfo:nil];
    [viewController appDidEnterBackground:mockNotification];
    XCTAssertTrue(mockContainerView.isPaused);

    [viewController fullscreenWebAdWillDisappear];
    XCTAssertTrue(mockContainerView.isPaused);

    [viewController fullscreenWebAdWillAppear];
    XCTAssertTrue(mockContainerView.isPaused);

    // The ad should not be resumed until both interruptions have ended.
    [viewController appWillEnterForeground:mockNotification];
    XCTAssertFalse(mockContainerView.isPaused);

    // Test in a different order
    [viewController appDidEnterBackground:mockNotification];
    XCTAssertTrue(mockContainerView.isPaused);

    [viewController fullscreenWebAdWillDisappear];
    XCTAssertTrue(mockContainerView.isPaused);

    [viewController appWillEnterForeground:mockNotification];
    XCTAssertTrue(mockContainerView.isPaused);

    [viewController fullscreenWebAdWillAppear];
    XCTAssertFalse(mockContainerView.isPaused);
}

- (void)testEndInterruptionDoesNotResumeIfNoCorrespondingStartInterruption {
    // Test to make sure that something that calls endInterruption does not
    // resume if there was no corresponding startInterruption call.
    MPFullscreenAdViewController *viewController = [MPFullscreenAdViewController new];

    MPAdContainerViewMock *mockContainerView = [MPAdContainerViewMock new];
    viewController.adContainerView = mockContainerView;

    NSNotification *mockNotification = [[NSNotification alloc] initWithName:@"mockNotification" object:nil userInfo:nil];
    [viewController appDidEnterBackground:mockNotification];
    XCTAssertTrue(mockContainerView.isPaused);

    // This calls endInterruption for clickthroughs, but since there was no
    // corresponding startInterruption call, this should not resume.
    [viewController fullscreenWebAdWillAppear];
    XCTAssertTrue(mockContainerView.isPaused);

    [viewController appWillEnterForeground:mockNotification];
    XCTAssertFalse(mockContainerView.isPaused);
}

@end
