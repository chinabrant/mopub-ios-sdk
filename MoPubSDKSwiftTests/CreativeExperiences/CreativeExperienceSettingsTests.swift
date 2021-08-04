//
//  CreativeExperienceSettingsTests.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import MoPubSDK

class CreativeExperienceSettingsTests: XCTestCase {
    func testValidData() {
        let json = """
        {
            "hash": "1234",
            "max_ad_time_secs": 30,
            "video_skip_thresholds_secs": [{
                "min": 5,
                "after": 10
            },
            {
                "min": 15,
                "after": 20
            }],
            "ec_durs_secs": {
                "static": 1,
                "interactive": 2,
                "min_static": 3,
                "min_interactive": 4
            },
            "main_ad": {
                "min_next_action_secs": 10,
                "cd_delay_secs": 5,
                "show_cd": 0
            },
            "end_card": {
                "min_next_action_secs": 20,
                "cd_delay_secs": 15,
                "show_cd": 0
            }
        }
        """
        
        guard let model: CreativeExperienceSettings = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.settingsHash, "1234")
        XCTAssertEqual(model.maxAdExperienceTime, 30.0)
        XCTAssertEqual(model.vastSkipThresholds.count, 2)
        XCTAssertEqual(model.vastSkipThresholds[0].skipMin, 5)
        XCTAssertEqual(model.vastSkipThresholds[0].skipAfter, 10)
        XCTAssertEqual(model.vastSkipThresholds[1].skipMin, 15)
        XCTAssertEqual(model.vastSkipThresholds[1].skipAfter, 20)
        XCTAssertEqual(model.endCardDurations.staticEndCardExperienceDuration, 1.0)
        XCTAssertEqual(model.endCardDurations.interactiveEndCardExperienceDuration, 2.0)
        XCTAssertEqual(model.endCardDurations.minStaticEndCardDuration, 3.0)
        XCTAssertEqual(model.endCardDurations.minInteractiveEndCardDuration, 4.0)
        XCTAssertEqual(model.adSettings.count, 2)
        XCTAssertEqual(model.adSettings[0].minTimeUntilNextAction, 10)
        XCTAssertEqual(model.adSettings[0].countdownTimerDelay, 5)
        XCTAssertEqual(model.adSettings[0].showCountdownTimer, false)
        XCTAssertEqual(model.adSettings[1].minTimeUntilNextAction, 20)
        XCTAssertEqual(model.adSettings[1].countdownTimerDelay, 15)
        XCTAssertEqual(model.adSettings[1].showCountdownTimer, false)
    }
    
    func testEncodeDecode() {
        let json = """
        {
            "hash": "1234",
            "max_ad_time_secs": 30,
            "video_skip_thresholds_secs": [{
                "min": 5,
                "after": 10
            },
            {
                "min": 15,
                "after": 20
            }],
            "ec_durs_secs": {
                "static": 1,
                "interactive": 2,
                "min_static": 3,
                "min_interactive": 4
            },
            "main_ad": {
                "min_next_action_secs": 10,
                "cd_delay_secs": 5,
                "show_cd": 0
            },
            "end_card": {
                "min_next_action_secs": 20,
                "cd_delay_secs": 15,
                "show_cd": 0
            }
        }
        """
        
        guard let model: CreativeExperienceSettings = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        guard let data = try? JSONEncoder().encode(model) else {
            XCTFail()
            return
        }
        
        guard let decodedModel = try? JSONDecoder().decode(CreativeExperienceSettings.self, from: data) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(decodedModel.settingsHash, "1234")
        XCTAssertEqual(decodedModel.maxAdExperienceTime, 30.0)
        XCTAssertEqual(decodedModel.vastSkipThresholds.count, 2)
        XCTAssertEqual(decodedModel.vastSkipThresholds[0].skipMin, 5)
        XCTAssertEqual(decodedModel.vastSkipThresholds[0].skipAfter, 10)
        XCTAssertEqual(decodedModel.vastSkipThresholds[1].skipMin, 15)
        XCTAssertEqual(decodedModel.vastSkipThresholds[1].skipAfter, 20)
        XCTAssertEqual(decodedModel.endCardDurations.staticEndCardExperienceDuration, 1.0)
        XCTAssertEqual(decodedModel.endCardDurations.interactiveEndCardExperienceDuration, 2.0)
        XCTAssertEqual(decodedModel.endCardDurations.minStaticEndCardDuration, 3.0)
        XCTAssertEqual(decodedModel.endCardDurations.minInteractiveEndCardDuration, 4.0)
        XCTAssertEqual(decodedModel.adSettings.count, 2)
        XCTAssertEqual(decodedModel.adSettings[0].minTimeUntilNextAction, 10)
        XCTAssertEqual(decodedModel.adSettings[0].countdownTimerDelay, 5)
        XCTAssertEqual(decodedModel.adSettings[0].showCountdownTimer, false)
        XCTAssertEqual(decodedModel.adSettings[1].minTimeUntilNextAction, 20)
        XCTAssertEqual(decodedModel.adSettings[1].countdownTimerDelay, 15)
        XCTAssertEqual(decodedModel.adSettings[1].showCountdownTimer, false)
    }
    
    func testUsesDefaultMainAdWhenMissing() {
        let json = """
        {
            "end_card": {
                "min_next_action_secs": 20,
                "cd_delay_secs": 15,
                "show_cd": 0
            }
        }
        """
        
        guard let model: CreativeExperienceSettings = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.adSettings.count, 2)
        XCTAssertEqual(model.adSettings[0], CreativeExperienceAdSettings.defaultValue)
        XCTAssertEqual(model.adSettings[1].minTimeUntilNextAction, 20)
        XCTAssertEqual(model.adSettings[1].countdownTimerDelay, 15)
        XCTAssertEqual(model.adSettings[1].showCountdownTimer, false)
    }
    
    func testEndCardUsesDefaultValuesWhenMissing() {
        let json = """
        {
            "main_ad": {
                "min_next_action_secs": 10,
                "cd_delay_secs": 5,
                "show_cd": 0
            }
        }
        """
        
        guard let model: CreativeExperienceSettings = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.adSettings.count, 2)
        XCTAssertEqual(model.adSettings[0].minTimeUntilNextAction, 10)
        XCTAssertEqual(model.adSettings[0].countdownTimerDelay, 5)
        XCTAssertEqual(model.adSettings[0].showCountdownTimer, false)
        XCTAssertEqual(model.adSettings[1], CreativeExperienceAdSettings.defaultValue)
    }
    
    func testUsesDefaultsWhenMissingValues() {
        let json = """
        {
        }
        """
        
        guard let model: CreativeExperienceSettings = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertNil(model.settingsHash)
        XCTAssertEqual(model.maxAdExperienceTime, 0.0)
        XCTAssertEqual(model.vastSkipThresholds.count, 1)
        XCTAssertEqual(model.vastSkipThresholds.first, VASTSkipThreshold.defaultValue)
        XCTAssertEqual(model.endCardDurations, EndCardDurations.defaultValue)
        XCTAssertEqual(model.adSettings.count, 2)
        XCTAssertEqual(model.adSettings[0], CreativeExperienceAdSettings.defaultValue)
        XCTAssertEqual(model.adSettings[1], CreativeExperienceAdSettings.defaultValue)
    }
    
    func testUsesDefaultsWhenArraysEmpty() {
        let json = """
        {
            "video_skip_thresholds_secs": []
        }
        """
        
        guard let model: CreativeExperienceSettings = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.vastSkipThresholds.count, 1)
        XCTAssertEqual(model.vastSkipThresholds.first, VASTSkipThreshold.defaultValue)
    }
    
    func testUsesDefaultsWhenValuesOutOfRange() {
        let json = """
        {
            "max_ad_time_secs": -1,
        }
        """
        
        guard let model: CreativeExperienceSettings = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.maxAdExperienceTime, 0.0)
    }
    
    func testUsesDefaultsWhenValuesIncorrectType() {
        let json = """
        {
            "hash": 1234,
            "max_ad_time_secs": "30",
            "video_skip_thresholds_secs": ["test"],
            "ec_durs_secs": "test",
            "main_ad": "test",
            "end_card": "test",
        }
        """
        
        guard let model: CreativeExperienceSettings = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertNil(model.settingsHash)
        XCTAssertEqual(model.maxAdExperienceTime, 0.0)
        XCTAssertEqual(model.vastSkipThresholds.count, 1)
        XCTAssertEqual(model.vastSkipThresholds.first, VASTSkipThreshold.defaultValue)
        XCTAssertEqual(model.endCardDurations, EndCardDurations.defaultValue)
        XCTAssertEqual(model.adSettings.count, 2)
        XCTAssertEqual(model.adSettings[0], CreativeExperienceAdSettings.defaultValue)
        XCTAssertEqual(model.adSettings[1], CreativeExperienceAdSettings.defaultValue)
    }
    
    func testRewardedUsesDefaultsWhenMissingValues() {
        let json = """
        {
        }
        """
        
        guard let model: CreativeExperienceSettings = CreativeExperienceTestHelpers.object(from: json, isRewarded: true) else {
            XCTFail()
            return
        }
        
        XCTAssertNil(model.settingsHash)
        XCTAssertEqual(model.maxAdExperienceTime, 30.0)
        XCTAssertEqual(model.vastSkipThresholds.count, 1)
        XCTAssertEqual(model.vastSkipThresholds.first, VASTSkipThreshold.defaultValueRewarded)
        XCTAssertEqual(model.endCardDurations, EndCardDurations.defaultValueRewarded)
        XCTAssertEqual(model.adSettings.count, 2)
        XCTAssertEqual(model.adSettings[0], CreativeExperienceAdSettings.defaultValueRewarded)
        // The end card always uses the defaultValue instead of defaultValueRewarded.
        XCTAssertEqual(model.adSettings[1], CreativeExperienceAdSettings.defaultValue)
    }
}
