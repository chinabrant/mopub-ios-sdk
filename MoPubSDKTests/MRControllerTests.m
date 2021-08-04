//
//  MRControllerTests.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdViewConstant.h"
#import "MRController+Testing.h"

#pragma mark - Test Utility (Resize Ad Frame Validation)

/**
 This class is for the test subject of resize ad frame validation tests.
 */
@interface MRControllerResizeAdFrameValidationTestSubject : NSObject
@property (nonatomic, assign) CGRect resizeFrame;
@property (nonatomic, assign) CGRect applicationSafeArea;
@property (nonatomic, assign) BOOL allowOffscreen;
@property (nonatomic, assign) BOOL expectedToBeValid;
@end

@implementation MRControllerResizeAdFrameValidationTestSubject

- (instancetype)initWithResizeFrame:(CGRect)resizeFrame
                applicationSafeArea:(CGRect)applicationSafeArea
                     allowOffscreen:(BOOL)allowOffscreen
                  expectedToBeValid:(BOOL)expectedToBeValid {
    self = [super init];
    if (self) {
        _resizeFrame = resizeFrame;
        _applicationSafeArea = applicationSafeArea;
        _allowOffscreen = allowOffscreen;
        _expectedToBeValid = expectedToBeValid;
    }
    return self;
}

+ (NSArray *)defaultTestSubjects {
    CGRect appSafeArea = CGRectMake(0, 20, 320, 460);
    CGRect invalidResizeFrame = CGRectZero;
    CGRect validOnScreenFrame = CGRectMake(10, 20, 300, 400);
    CGRect validOnScreenFrameSmallest = CGRectMake(100, 100, 50, 50); // MRAID spec indicates a minimal 50x50 ad size
    CGRect validOnScreenFrameFullScreen = appSafeArea;
    CGRect validFullyOffScreenFrame = CGRectMake(-200, -200, 100, 100);
    CGRect validPartiallyOffScreenFrame = CGRectMake(-100, -100, 200, 200);

    return @[// resize frames with invalid size
             [[MRControllerResizeAdFrameValidationTestSubject alloc] initWithResizeFrame:invalidResizeFrame
                                                                     applicationSafeArea:appSafeArea
                                                                          allowOffscreen:NO
                                                                       expectedToBeValid:NO],
             [[MRControllerResizeAdFrameValidationTestSubject alloc] initWithResizeFrame:invalidResizeFrame
                                                                     applicationSafeArea:appSafeArea
                                                                          allowOffscreen:YES
                                                                       expectedToBeValid:NO],

             // on screen resize frames with valide size
             [[MRControllerResizeAdFrameValidationTestSubject alloc] initWithResizeFrame:validOnScreenFrame
                                                                     applicationSafeArea:appSafeArea
                                                                          allowOffscreen:NO
                                                                       expectedToBeValid:YES],
             [[MRControllerResizeAdFrameValidationTestSubject alloc] initWithResizeFrame:validOnScreenFrame
                                                                     applicationSafeArea:appSafeArea
                                                                          allowOffscreen:YES
                                                                       expectedToBeValid:YES],

             [[MRControllerResizeAdFrameValidationTestSubject alloc] initWithResizeFrame:validOnScreenFrameSmallest
                                                                     applicationSafeArea:appSafeArea
                                                                          allowOffscreen:NO
                                                                       expectedToBeValid:YES],
             [[MRControllerResizeAdFrameValidationTestSubject alloc] initWithResizeFrame:validOnScreenFrameSmallest
                                                                     applicationSafeArea:appSafeArea
                                                                          allowOffscreen:YES
                                                                       expectedToBeValid:YES],

             [[MRControllerResizeAdFrameValidationTestSubject alloc] initWithResizeFrame:validOnScreenFrameFullScreen
                                                                     applicationSafeArea:appSafeArea
                                                                          allowOffscreen:NO
                                                                       expectedToBeValid:YES],
             [[MRControllerResizeAdFrameValidationTestSubject alloc] initWithResizeFrame:validOnScreenFrameFullScreen
                                                                     applicationSafeArea:appSafeArea
                                                                          allowOffscreen:YES
                                                                       expectedToBeValid:YES],

             // off screen resize frames with valide size
             [[MRControllerResizeAdFrameValidationTestSubject alloc] initWithResizeFrame:validFullyOffScreenFrame
                                                                     applicationSafeArea:appSafeArea
                                                                          allowOffscreen:NO
                                                                       expectedToBeValid:NO],
             [[MRControllerResizeAdFrameValidationTestSubject alloc] initWithResizeFrame:validFullyOffScreenFrame
                                                                     applicationSafeArea:appSafeArea
                                                                          allowOffscreen:YES
                                                                       expectedToBeValid:YES],

             [[MRControllerResizeAdFrameValidationTestSubject alloc] initWithResizeFrame:validPartiallyOffScreenFrame
                                                                     applicationSafeArea:appSafeArea
                                                                          allowOffscreen:NO
                                                                       expectedToBeValid:NO],
             [[MRControllerResizeAdFrameValidationTestSubject alloc] initWithResizeFrame:validPartiallyOffScreenFrame
                                                                     applicationSafeArea:appSafeArea
                                                                          allowOffscreen:YES
                                                                       expectedToBeValid:YES]
             ];
}

@end

#pragma mark - Tests

@interface MRControllerTests : XCTestCase

@end

@implementation MRControllerTests

/**
 Test the result of [MRController isValidResizeFrame:inApplicationSafeArea:allowOffscreen:].
 */
- (void)testResizeAdFrameValidation {
    for (MRControllerResizeAdFrameValidationTestSubject * t in [MRControllerResizeAdFrameValidationTestSubject defaultTestSubjects]) {
        XCTAssertEqual(t.expectedToBeValid, [MRController isValidResizeFrame:t.resizeFrame
                                                       inApplicationSafeArea:t.applicationSafeArea
                                                              allowOffscreen:t.allowOffscreen]);
    }
}

/**
 Test the result of [MRController adjustedFrameForFrame:toFitIntoApplicationSafeArea:].
 */
- (void)testAdjustedAdFrame {
    // Test a frame that already fits.
    XCTAssertTrue(CGRectEqualToRect(CGRectMake(100, 100, 100, 100),
                                    [MRController adjustedFrameForFrame:CGRectMake(100, 100, 100, 100)
                                                  toFitIntoApplicationSafeArea:CGRectMake(0, 0, 500, 500)]));

    // Test a frame that fits after adjustment.
    XCTAssertTrue(CGRectEqualToRect(CGRectMake(0, 0, 100, 100),
                                    [MRController adjustedFrameForFrame:CGRectMake(100, 100, 100, 100)
                                           toFitIntoApplicationSafeArea:CGRectMake(0, 0, 100, 100)]));
    XCTAssertTrue(CGRectEqualToRect(CGRectMake(200, 200, 100, 100),
                                    [MRController adjustedFrameForFrame:CGRectMake(100, 100, 100, 100)
                                           toFitIntoApplicationSafeArea:CGRectMake(200, 200, 100, 100)]));

    // Test a frame that cannot fit due to large size (thus is not adjusted).
    XCTAssertTrue(CGRectEqualToRect(CGRectMake(0, 0, 100, 100),
                                    [MRController adjustedFrameForFrame:CGRectMake(0, 0, 100, 100)
                                           toFitIntoApplicationSafeArea:CGRectMake(10, 10, 10, 10)]));
}

@end
