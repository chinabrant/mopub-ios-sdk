//
//  CreativeExperiencesManagerTests.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import MoPubSDK

class CreativeExperiencesManagerTests: XCTestCase {
    override class func setUp() {
        MPDiskLRUCache.sharedDisk().removeAllCachedFiles()
    }

    func testReturnsNilWhenNoSettingsCached() {
        let settings = CreativeExperiencesManager.shared.cachedSettings(for: Constants.adUnitID)
        XCTAssertNil(settings)
    }
    
    func testReturnsValidCachedSettings() {
        let settings = CreativeExperienceTestHelpers.creativeExperienceSettings(settingsHash: "testHash")
        CreativeExperiencesManager.shared.cache(settings: settings, for: Constants.adUnitID)
        
        guard let cachedSettings = CreativeExperiencesManager.shared.cachedSettings(for: Constants.adUnitID) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(cachedSettings.settingsHash, "testHash")
    }
    
    func testSettingsOverwrite() {
        let settings1 = CreativeExperienceTestHelpers.creativeExperienceSettings(settingsHash: "testHash")
        CreativeExperiencesManager.shared.cache(settings: settings1, for: Constants.adUnitID)
        
        guard let cachedSettings1 = CreativeExperiencesManager.shared.cachedSettings(for: Constants.adUnitID) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(cachedSettings1.settingsHash, "testHash")
        
        let settings2 = CreativeExperienceTestHelpers.creativeExperienceSettings(settingsHash: "differentHash")
        CreativeExperiencesManager.shared.cache(settings: settings2, for: Constants.adUnitID)
        
        guard let cachedSettings2 = CreativeExperiencesManager.shared.cachedSettings(for: Constants.adUnitID) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(cachedSettings2.settingsHash, "differentHash")
    }
}

// MARK: - Constants
private extension CreativeExperiencesManagerTests {
    struct Constants {
        static let adUnitID = "testAdUnitID"
    }
}
