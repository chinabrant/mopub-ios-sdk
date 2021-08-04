//
//  CreativeExperiencesFormulasTests.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import MoPubSDK

class CreativeExperiencesFormulasTests: XCTestCase {
    // MARK: - Countdown Time
    func testCountdownTimeIndexLessThanZero() {
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings()
        let countdownTime = settings.countdownTime(for: .other, index: -1, elapsedTime: 0)
        XCTAssertEqual(countdownTime, 0)
    }
    
    func testCountdownTimeIndexGreaterThanNumberOfAdSettings() {
        let mainAd = CreativeExperienceAdSettings(minTimeUntilNextAction: 5, countdownTimerDelay: 0, showCountdownTimer: true)
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(maxAdExperienceTime: 0, mainAd: mainAd)
        
        // Make sure countdown time for the first ad is correct.
        XCTAssertEqual(settings.countdownTime(for: .other, index: 0, elapsedTime: 0), 5)
        
        // But there are no ad settings at index 1, so that should return 0.
        XCTAssertEqual(settings.countdownTime(for: .other, index: 1, elapsedTime: 0), 0)
    }
    
    func testCountdownTimeNegativeElapsedTime() {
        let mainAd = CreativeExperienceAdSettings(minTimeUntilNextAction: 5, countdownTimerDelay: 0, showCountdownTimer: true)
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(maxAdExperienceTime: 30, mainAd: mainAd)
        
        // elapsedTime will be clamped to 0, so this will just evaluate to
        // maxAdExperienceTime.
        XCTAssertEqual(settings.countdownTime(for: .other, index: 0, elapsedTime: -5), 30)
    }
    
    func testCountdownTimeLargeElapsedTime() {
        let mainAd = CreativeExperienceAdSettings(minTimeUntilNextAction: 5, countdownTimerDelay: 0, showCountdownTimer: true)
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(maxAdExperienceTime: 30, mainAd: mainAd)
        
        // Using an elapsed time much larger than the maxAdExperienceTime
        // will just result in using the minTimeUntilNextAction.
        XCTAssertEqual(settings.countdownTime(for: .other, index: 0, elapsedTime: 999), 5)
    }
    
    // Other ad type, Non-Rewarded
    func testCountdownTimeNonVASTAdNonRewarded() {
        let mainAd = CreativeExperienceAdSettings(minTimeUntilNextAction: 5, countdownTimerDelay: 0, showCountdownTimer: true)
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(maxAdExperienceTime: 0, mainAd: mainAd)
        
        XCTAssertEqual(settings.countdownTime(for: .other, index: 0, elapsedTime: 0), 5)
    }
    
    // Other ad type, Rewarded
    func testCountdownTimeNonVASTAdRewarded() {
        let mainAd = CreativeExperienceAdSettings(minTimeUntilNextAction: 5, countdownTimerDelay: 0, showCountdownTimer: true)
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(maxAdExperienceTime: 30, mainAd: mainAd)
        
        // For the first ad in the experience, the countdownTime should be minTimeUntilNextAction.
        XCTAssertEqual(settings.countdownTime(for: .other, index: 0, elapsedTime: 0), 30)
    }
    
    // VAST Video, Video Only, Skippable, Non-Rewarded
    func testCountdownTimeVASTVideoSkippableNonRewarded() {
        // Intentially use a skipAfter that's different from minTimeUntilNextAction.
        let skipThresholds = [
            VASTSkipThreshold(skipMin: 15, skipAfter: 5)
        ]
        let mainAd = CreativeExperienceAdSettings(minTimeUntilNextAction: 20, countdownTimerDelay: 0, showCountdownTimer: true)
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(maxAdExperienceTime: 0,
                                                                                vastSkipThresholds: skipThresholds,
                                                                                mainAd: mainAd)
        
        let adType = CreativeExperienceSettings.AdType.vast(30, .none)
        
        XCTAssertEqual(settings.countdownTime(for: adType, index: 0, elapsedTime: 0), 5)
    }
    
    // VAST Video, Video Only, Non-Skippable, Non-Rewarded
    func testCountdownTimeVASTVideoNonSkippableNonRewarded() {
        // Intentially use a skipAfter that's different from minTimeUntilNextAction.
        let skipThresholds = [
            VASTSkipThreshold(skipMin: 15, skipAfter: 5)
        ]
        let mainAd = CreativeExperienceAdSettings(minTimeUntilNextAction: 20, countdownTimerDelay: 0, showCountdownTimer: true)
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(maxAdExperienceTime: 0,
                                                                                vastSkipThresholds: skipThresholds,
                                                                                mainAd: mainAd)
        
        let adType = CreativeExperienceSettings.AdType.vast(10, .none)
        
        XCTAssertEqual(settings.countdownTime(for: adType, index: 0, elapsedTime: 0), 10)
    }
    
    // VAST Video, Video Only, Rewarded
    func testCountdownTimeVASTVideoSkippableRewarded() {
        // Intentially use a skipAfter that's different from minTimeUntilNextAction.
        let skipThresholds = [
            VASTSkipThreshold(skipMin: 15, skipAfter: 5)
        ]
        let mainAd = CreativeExperienceAdSettings(minTimeUntilNextAction: 20, countdownTimerDelay: 0, showCountdownTimer: true)
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(maxAdExperienceTime: 30,
                                                                                vastSkipThresholds: skipThresholds,
                                                                                mainAd: mainAd)
        
        // In this case, since there is no end card, we allow the user
        // to exit early even though there is still maxAdExperienceTime
        // left.
        let shortAdType = CreativeExperienceSettings.AdType.vast(10, .none)
        XCTAssertEqual(settings.countdownTime(for: shortAdType, index: 0, elapsedTime: 0), 10)
        
        let longAdType = CreativeExperienceSettings.AdType.vast(40, .none)
        XCTAssertEqual(settings.countdownTime(for: longAdType, index: 0, elapsedTime: 0), 30)
    }
    
    // VAST Video, Video and End Card, Skippable, Non-Rewarded
    func testCountdownTimeVASTVideoAndEndCardSkippableNonRewarded() {
        // Intentially use a skipAfter that's different from minTimeUntilNextAction.
        let skipThresholds = [
            VASTSkipThreshold(skipMin: 15, skipAfter: 5)
        ]
        
        // Since maxAdExperienceTime is 0, we don't need to worry about the
        // end card experience durations.
        let endCardDurations = EndCardDurations(staticEndCardExperienceDuration: 0,
                                                interactiveEndCardExperienceDuration: 0,
                                                minStaticEndCardDuration: 5,
                                                minInteractiveEndCardDuration: 0)
        let mainAdSettings = CreativeExperienceAdSettings(minTimeUntilNextAction: 20, countdownTimerDelay: 0, showCountdownTimer: true)
        let endCardSettings = CreativeExperienceAdSettings(minTimeUntilNextAction: 20, countdownTimerDelay: 0, showCountdownTimer: true)
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(maxAdExperienceTime: 0,
                                                                                vastSkipThresholds: skipThresholds,
                                                                                endCardDurations: endCardDurations,
                                                                                mainAd: mainAdSettings,
                                                                                endCard: endCardSettings)
        
        let adType = CreativeExperienceSettings.AdType.vast(30, .static)
        
        XCTAssertEqual(settings.countdownTime(for: adType, index: 0, elapsedTime: 0), 5)
        
        // Since maxAdExperienceTime is 0, the countdown time for the end card
        // will always be 5.
        XCTAssertEqual(settings.countdownTime(for: adType, index: 1, elapsedTime: 5), 5)
        XCTAssertEqual(settings.countdownTime(for: adType, index: 1, elapsedTime: 30), 5)
    }
    
    // VAST Video, Video and End Card, Non-Skippable, Non-Rewarded
    func testCountdownTimeVASTVideoAndEndCardNonSkippableNonRewarded() {
        // Intentially use a skipAfter that's different from minTimeUntilNextAction.
        let skipThresholds = [
            VASTSkipThreshold(skipMin: 15, skipAfter: 5)
        ]
        
        // Since maxAdExperienceTime is 0, we don't need to worry about the
        // end card experience durations.
        let endCardDurations = EndCardDurations(staticEndCardExperienceDuration: 0,
                                                interactiveEndCardExperienceDuration: 0,
                                                minStaticEndCardDuration: 5,
                                                minInteractiveEndCardDuration: 0)
        let mainAdSettings = CreativeExperienceAdSettings(minTimeUntilNextAction: 20, countdownTimerDelay: 0, showCountdownTimer: true)
        let endCardSettings = CreativeExperienceAdSettings(minTimeUntilNextAction: 20, countdownTimerDelay: 0, showCountdownTimer: true)
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(maxAdExperienceTime: 0,
                                                                                vastSkipThresholds: skipThresholds,
                                                                                endCardDurations: endCardDurations,
                                                                                mainAd: mainAdSettings,
                                                                                endCard: endCardSettings)
                
        let adType = CreativeExperienceSettings.AdType.vast(10, .static)
        
        XCTAssertEqual(settings.countdownTime(for: adType, index: 0, elapsedTime: 0), 10)
        
        // Since maxAdExperienceTime is 0, the countdown time for the end card
        // will always be 5.
        XCTAssertEqual(settings.countdownTime(for: adType, index: 1, elapsedTime: 5), 5)
        XCTAssertEqual(settings.countdownTime(for: adType, index: 1, elapsedTime: 30), 5)
    }
    
    // VAST Video, Video and End Card, Skippable, Rewarded
    func testCountdownTimeVASTVideoAndEndCardSkippableRewarded() {
        // Intentially use a skipAfter that's different from minTimeUntilNextAction.
        let skipThresholds = [
            VASTSkipThreshold(skipMin: 15, skipAfter: 5)
        ]
        
        let endCardDurations = EndCardDurations(staticEndCardExperienceDuration: 10,
                                                interactiveEndCardExperienceDuration: 0,
                                                minStaticEndCardDuration: 5,
                                                minInteractiveEndCardDuration: 0)
        
        let mainAdSettings = CreativeExperienceAdSettings(minTimeUntilNextAction: 20, countdownTimerDelay: 0, showCountdownTimer: true)
        let endCardSettings = CreativeExperienceAdSettings(minTimeUntilNextAction: 20, countdownTimerDelay: 0, showCountdownTimer: true)
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(maxAdExperienceTime: 30,
                                                                                vastSkipThresholds: skipThresholds,
                                                                                endCardDurations: endCardDurations,
                                                                                mainAd: mainAdSettings,
                                                                                endCard: endCardSettings)
        
        let adType = CreativeExperienceSettings.AdType.vast(30, .static)
        
        // maxAdExperienceTime < videoDuration + staticEndCardExperienceDuration,
        // so closeAfter is 30 seconds.
        XCTAssertEqual(settings.countdownTime(for: adType, index: 0, elapsedTime: 0), 5)
        
        XCTAssertEqual(settings.countdownTime(for: adType, index: 1, elapsedTime: 5), 25)
        XCTAssertEqual(settings.countdownTime(for: adType, index: 1, elapsedTime: 10), 20)
        XCTAssertEqual(settings.countdownTime(for: adType, index: 1, elapsedTime: 25), 5)
        
        // The user must always wait at least minStaticEndCardDuration on
        // the end card.
        XCTAssertEqual(settings.countdownTime(for: adType, index: 1, elapsedTime: 30), 5)
    }
    
    // VAST Video, Video and End Card, Non-Skippable, Rewarded
    func testCountdownTimeVASTVideoAndEndCardNonSkippableRewarded() {
        // Intentially use a skipAfter that's different from minTimeUntilNextAction.
        let skipThresholds = [
            VASTSkipThreshold(skipMin: 15, skipAfter: 5)
        ]
        
        let endCardDurations = EndCardDurations(staticEndCardExperienceDuration: 10,
                                                interactiveEndCardExperienceDuration: 0,
                                                minStaticEndCardDuration: 5,
                                                minInteractiveEndCardDuration: 0)
        let mainAdSettings = CreativeExperienceAdSettings(minTimeUntilNextAction: 20, countdownTimerDelay: 0, showCountdownTimer: true)
        let endCardSettings = CreativeExperienceAdSettings(minTimeUntilNextAction: 20, countdownTimerDelay: 0, showCountdownTimer: true)
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(maxAdExperienceTime: 30,
                                                                                vastSkipThresholds: skipThresholds,
                                                                                endCardDurations: endCardDurations,
                                                                                mainAd: mainAdSettings,
                                                                                endCard: endCardSettings)
        
        let adType = CreativeExperienceSettings.AdType.vast(10, .static)
        
        XCTAssertEqual(settings.countdownTime(for: adType, index: 0, elapsedTime: 0), 10)
        
        // maxAdExperienceTime > videoDuration + staticEndCardExperienceDuration,
        // so closeAfter is 20 seconds.
        XCTAssertEqual(settings.countdownTime(for: adType, index: 1, elapsedTime: 10), 10)
        
        // These scenarios technically aren't possible (since the video ends
        // after 10 seconds, after which the end card will be shown), but they
        // are good to test to make sure the formulas are working as expected.
        XCTAssertEqual(settings.countdownTime(for: adType, index: 1, elapsedTime: 15), 5)
        XCTAssertEqual(settings.countdownTime(for: adType, index: 1, elapsedTime: 20), 5)
    }
    
    // Test the edge case that we have 2 ad settings objects, but no
    // end card. The second ad settings object should be ignored, and the
    // video should be considered the last ad in the experience.
    func testCountdownTimeVASTVideoNoEndCardMultipleAdSettings() {
        let skipThresholds = [
            VASTSkipThreshold(skipMin: 15, skipAfter: 5)
        ]
        
        let endCardDurations = EndCardDurations(staticEndCardExperienceDuration: 0,
                                                interactiveEndCardExperienceDuration: 0,
                                                minStaticEndCardDuration: 0,
                                                minInteractiveEndCardDuration: 0)
        let mainAdSettings = CreativeExperienceAdSettings(minTimeUntilNextAction: 20, countdownTimerDelay: 0, showCountdownTimer: true)
        let endCardSettings = CreativeExperienceAdSettings(minTimeUntilNextAction: 20, countdownTimerDelay: 0, showCountdownTimer: true)
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(maxAdExperienceTime: 30,
                                                                                vastSkipThresholds: skipThresholds,
                                                                                endCardDurations: endCardDurations,
                                                                                mainAd: mainAdSettings,
                                                                                endCard: endCardSettings)
        
        let adType = CreativeExperienceSettings.AdType.vast(30, .none)
        
        XCTAssertEqual(settings.countdownTime(for: adType, index: 0, elapsedTime: 0), 30)
    }
    
    // MARK: - Close After
    func testCloseAfterEndCardDurations() {
        let endCardDurations = EndCardDurations(staticEndCardExperienceDuration: 2,
                                                interactiveEndCardExperienceDuration: 3,
                                                minStaticEndCardDuration: 0,
                                                minInteractiveEndCardDuration: 0)
        
        // Use a large maxAdExperience time so the result is based on video
        // duration and end card experience duration.
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(maxAdExperienceTime: 999, endCardDurations: endCardDurations)
        
        XCTAssertEqual(settings.closeAfterDuration(for: 5, endCardType: .none), 5)
        XCTAssertEqual(settings.closeAfterDuration(for: 5, endCardType: .interactive), 8)
        XCTAssertEqual(settings.closeAfterDuration(for: 5, endCardType: .static), 7)
    }
    
    func testCloseAfterMaxAdExperienceTimeGreaterThanSum() {
        let endCardDurations = EndCardDurations(staticEndCardExperienceDuration: 2,
                                                interactiveEndCardExperienceDuration: 3,
                                                minStaticEndCardDuration: 0,
                                                minInteractiveEndCardDuration: 0)
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(maxAdExperienceTime: 30, endCardDurations: endCardDurations)
        let closeAfter = settings.closeAfterDuration(for: 5, endCardType: .none)
        XCTAssertEqual(closeAfter, 5)
    }
    
    func testCloseAfterMaxAdExperienceTimeLessThanSum() {
        let endCardDurations = EndCardDurations(staticEndCardExperienceDuration: 20,
                                                interactiveEndCardExperienceDuration: 30,
                                                minStaticEndCardDuration: 0,
                                                minInteractiveEndCardDuration: 0)
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(maxAdExperienceTime: 30, endCardDurations: endCardDurations)
        let closeAfter = settings.closeAfterDuration(for: 5, endCardType: .interactive)
        XCTAssertEqual(closeAfter, 30)
    }
    
    func testCloseAfterNegativeVideoDuration() {
        let endCardDurations = EndCardDurations(staticEndCardExperienceDuration: 2,
                                                interactiveEndCardExperienceDuration: 3,
                                                minStaticEndCardDuration: 0,
                                                minInteractiveEndCardDuration: 0)
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(maxAdExperienceTime: 30, endCardDurations: endCardDurations)
        // If we pass in a negative value for video duration, we clamp it to 0.
        let closeAfter = settings.closeAfterDuration(for: -5, endCardType: .interactive)
        XCTAssertEqual(closeAfter, 3)
    }
    
    // MARK: - Time Until Next Action
    func testTimeUntilNextActionForVideo() {
        // Intentially out of order skip thresholds.
        let skipThresholds = [
            VASTSkipThreshold(skipMin: 10, skipAfter: 1),
            VASTSkipThreshold(skipMin: 30, skipAfter: 3),
            VASTSkipThreshold(skipMin: 20, skipAfter: 2)
        ]
        
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(vastSkipThresholds: skipThresholds)
        
        XCTAssertEqual(settings.timeUntilNextActionDuration(for: 35), 3)
        XCTAssertEqual(settings.timeUntilNextActionDuration(for: 30), 3)
        XCTAssertEqual(settings.timeUntilNextActionDuration(for: 29), 2)
        XCTAssertEqual(settings.timeUntilNextActionDuration(for: 20), 2)
        XCTAssertEqual(settings.timeUntilNextActionDuration(for: 15), 1)
        XCTAssertEqual(settings.timeUntilNextActionDuration(for: 5), 5)
    }
    
    func testTimeUntilNextActionNegativeVideoDuration() {
        let skipThresholds = [
            VASTSkipThreshold(skipMin: 15, skipAfter: 5)
        ]
        
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(vastSkipThresholds: skipThresholds)
        
        XCTAssertEqual(settings.timeUntilNextActionDuration(for: -1), 0)
    }
    
    func testTimeUntilNextActionSkipAfterGreaterThanVideoDuration() {
        let skipThresholds = [
            VASTSkipThreshold(skipMin: 10, skipAfter: 30)
        ]
        
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(vastSkipThresholds: skipThresholds)
        
        // If skipAfter is greater than the video duration, we return
        // the video duration.
        XCTAssertEqual(settings.timeUntilNextActionDuration(for: 15), 15)
    }
    
    func testTimeUntilNextActionForEndCards() {
        let endCardDurations = EndCardDurations(staticEndCardExperienceDuration: 0,
                                                interactiveEndCardExperienceDuration: 0,
                                                minStaticEndCardDuration: 1,
                                                minInteractiveEndCardDuration: 2)
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(endCardDurations: endCardDurations)
        
        XCTAssertEqual(settings.timeUntilNextActionDuration(for: .interactive), 2)
        XCTAssertEqual(settings.timeUntilNextActionDuration(for: .static), 1)
        XCTAssertEqual(settings.timeUntilNextActionDuration(for: .none), 0)
    }
}
