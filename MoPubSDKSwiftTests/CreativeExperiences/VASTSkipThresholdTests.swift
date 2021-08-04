//
//  VASTSkipThresholdTests.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import MoPubSDK

class VASTSkipThresholdTests: XCTestCase {
    func testValidData() {
        let json = """
        {
            "min": 30,
            "after": 15
        }
        """
        
        guard let model: VASTSkipThreshold = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.skipMin, 30.0)
        XCTAssertEqual(model.skipAfter, 15.0)
    }
    
    func testEncodeDecode() {
        let json = """
        {
            "min": 30,
            "after": 15
        }
        """
        
        guard let model: VASTSkipThreshold = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        guard let data = try? JSONEncoder().encode(model) else {
            XCTFail()
            return
        }
        
        guard let decodedModel = try? JSONDecoder().decode(VASTSkipThreshold.self, from: data) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(decodedModel.skipMin, 30.0)
        XCTAssertEqual(decodedModel.skipAfter, 15.0)
    }
    
    func testUsesDefaultsWhenMissingValues() {
        let json = """
        {
        }
        """
        
        guard let model: VASTSkipThreshold = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.skipMin, 16.0)
        XCTAssertEqual(model.skipAfter, 5.0)
    }
    
    func testUsesDefaultsWhenValuesOutOfRange() {
        let json = """
        {
            "min": -1,
            "after": -1
        }
        """
        
        guard let model: VASTSkipThreshold = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.skipMin, 16.0)
        XCTAssertEqual(model.skipAfter, 5.0)
    }
    
    func testUsesDefaultsWhenValuesIncorrectType() {
        let json = """
        {
            "min": "5",
            "after": "10"
        }
        """
        
        guard let model: VASTSkipThreshold = CreativeExperienceTestHelpers.object(from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.skipMin, 16.0)
        XCTAssertEqual(model.skipAfter, 5.0)
    }
    
    func testRewardedUsesDefaultsWhenMissingValues() {
        let json = """
        {
        }
        """
        
        guard let model: VASTSkipThreshold = CreativeExperienceTestHelpers.object(from: json, isRewarded: true) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(model.skipMin, 0.0)
        XCTAssertEqual(model.skipAfter, 30.0)
    }
}
