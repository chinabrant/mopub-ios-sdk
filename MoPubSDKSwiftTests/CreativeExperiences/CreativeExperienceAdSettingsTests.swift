//
//  CreativeExperienceAdSettingsTests.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import MoPubSDK

class CreativeExperienceAdSettingsTests: XCTestCase {
    func testValidData() {
        let json = """
        {
            "min_next_action_secs": 10,
            "cd_delay_secs": 5,
            "show_cd": 0
        }
        """
        
        guard let model: CreativeExperienceAdSettings = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.minTimeUntilNextAction, 10.0)
        XCTAssertEqual(model.countdownTimerDelay, 5.0)
        
        // Test false since true is the default value.
        XCTAssertEqual(model.showCountdownTimer, false)
    }
    
    func testEncodeDecode() {
        let json = """
        {
            "min_next_action_secs": 10,
            "cd_delay_secs": 5,
            "show_cd": 0
        }
        """
        
        guard let model: CreativeExperienceAdSettings = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        guard let data = try? JSONEncoder().encode(model) else {
            XCTFail()
            return
        }
        
        guard let decodedModel = try? JSONDecoder().decode(CreativeExperienceAdSettings.self, from: data) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(decodedModel.minTimeUntilNextAction, 10.0)
        XCTAssertEqual(decodedModel.countdownTimerDelay, 5.0)
        XCTAssertEqual(decodedModel.showCountdownTimer, false)
    }
    
    func testUsesDefaultsWhenMissingValues() {
        let json = """
        {
        }
        """
        
        guard let model: CreativeExperienceAdSettings = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.minTimeUntilNextAction, 0.0)
        XCTAssertEqual(model.countdownTimerDelay, 0.0)
        XCTAssertEqual(model.showCountdownTimer, true)
    }
    
    func testUsesDefaultsWhenValuesOutOfRange() {
        let json = """
        {
            "min_next_action_secs": -1,
            "cd_delay_secs": -1,
        }
        """
        
        guard let model: CreativeExperienceAdSettings = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.minTimeUntilNextAction, 0.0)
        XCTAssertEqual(model.countdownTimerDelay, 0.0)
    }
    
    func testUsesDefaultsWhenValuesIncorrectType() {
        let json = """
        {
            "min_next_action_secs": "hello",
            "cd_delay_secs": "world",
        }
        """
        
        guard let model: CreativeExperienceAdSettings = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.minTimeUntilNextAction, 0.0)
        XCTAssertEqual(model.countdownTimerDelay, 0.0)
    }
    
    func testShowCountdownTimerBoolean() {
        let json = """
        {
            "show_cd": false
        }
        """
        
        guard let model: CreativeExperienceAdSettings = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        // We need to support both boolean and integer, since the server
        // sends integers, but the model is re-encoded as a boolean.
        XCTAssertEqual(model.showCountdownTimer, false)
    }
    
    func testShowCountdownTimerUsesDefaultsWhenValueIsOutOfRange() {
        let json = """
        {
            "show_cd": 2
        }
        """
        
        guard let model: CreativeExperienceAdSettings = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        // Test to make sure an out of range integer uses the default value.
        XCTAssertEqual(model.showCountdownTimer, true)
    }
    
    func testShowCountdownTimerUsesDefaultsWhenValueIsString() {
        let json = """
        {
            "show_cd": "0"
        }
        """
        
        guard let model: CreativeExperienceAdSettings = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        // Use the default value if the value is a string.
        XCTAssertEqual(model.showCountdownTimer, true)
    }
    
    func testRewardedUsesDefaultsWhenMissingValues() {
        let json = """
        {
        }
        """
        
        guard let model: CreativeExperienceAdSettings = CreativeExperienceTestHelpers.object(from: json, isRewarded: true) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.minTimeUntilNextAction, 30.0)
        XCTAssertEqual(model.countdownTimerDelay, 0.0)
        XCTAssertEqual(model.showCountdownTimer, true)
    }
}
