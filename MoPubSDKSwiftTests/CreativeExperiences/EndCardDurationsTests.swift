//
//  EndCardDurationsTests.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import MoPubSDK

class EndCardDurationsTests: XCTestCase {
    func testValidData() {
        let json = """
        {
            "static": 1,
            "interactive": 2,
            "min_static": 3,
            "min_interactive": 4
        }
        """
        
        guard let model: EndCardDurations = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.staticEndCardExperienceDuration, 1.0)
        XCTAssertEqual(model.interactiveEndCardExperienceDuration, 2.0)
        XCTAssertEqual(model.minStaticEndCardDuration, 3.0)
        XCTAssertEqual(model.minInteractiveEndCardDuration, 4.0)
    }
    
    func testEncodeDecode() {
        let json = """
        {
            "static": 1,
            "interactive": 2,
            "min_static": 3,
            "min_interactive": 4
        }
        """
        
        guard let model: EndCardDurations = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        guard let data = try? JSONEncoder().encode(model) else {
            XCTFail()
            return
        }
        
        guard let decodedModel = try? JSONDecoder().decode(EndCardDurations.self, from: data) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(decodedModel.staticEndCardExperienceDuration, 1.0)
        XCTAssertEqual(decodedModel.interactiveEndCardExperienceDuration, 2.0)
        XCTAssertEqual(decodedModel.minStaticEndCardDuration, 3.0)
        XCTAssertEqual(decodedModel.minInteractiveEndCardDuration, 4.0)
    }
    
    func testUsesDefaultsWhenMissingValues() {
        let json = """
        {
        }
        """
        
        guard let model: EndCardDurations = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.staticEndCardExperienceDuration, 0.0)
        XCTAssertEqual(model.interactiveEndCardExperienceDuration, 0.0)
        XCTAssertEqual(model.minStaticEndCardDuration, 0.0)
        XCTAssertEqual(model.minInteractiveEndCardDuration, 0.0)
    }
    
    func testUsesDefaultsWhenValuesOutOfRange() {
        let json = """
        {
            "static": -1,
            "interactive": -1,
            "min_static": -1,
            "min_interactive": -1
        }
        """
        
        guard let model: EndCardDurations = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.staticEndCardExperienceDuration, 0.0)
        XCTAssertEqual(model.interactiveEndCardExperienceDuration, 0.0)
        XCTAssertEqual(model.minStaticEndCardDuration, 0.0)
        XCTAssertEqual(model.minInteractiveEndCardDuration, 0.0)
    }
    
    func testUsesDefaultsWhenValuesIncorrectType() {
        let json = """
        {
            "static": "1",
            "interactive": "2",
            "min_static": "3",
            "min_interactive": "4"
        }
        """
        
        guard let model: EndCardDurations = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.staticEndCardExperienceDuration, 0.0)
        XCTAssertEqual(model.interactiveEndCardExperienceDuration, 0.0)
        XCTAssertEqual(model.minStaticEndCardDuration, 0.0)
        XCTAssertEqual(model.minInteractiveEndCardDuration, 0.0)
    }
    
    func testRewardedUsesDefaultsWhenMissingValues() {
        let json = """
        {
        }
        """
        
        guard let model: EndCardDurations = CreativeExperienceTestHelpers.object(from: json, isRewarded: true) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.staticEndCardExperienceDuration, 5.0)
        XCTAssertEqual(model.interactiveEndCardExperienceDuration, 10.0)
        XCTAssertEqual(model.minStaticEndCardDuration, 0.0)
        XCTAssertEqual(model.minInteractiveEndCardDuration, 0.0)
    }
}
