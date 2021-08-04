//
//  CreativeExperienceTestHelpers.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation
@testable import MoPubSDK

@objc public
class CreativeExperienceTestHelpers: NSObject {
    /// Obj-C helper function to create a `CreativeExperienceSettings` object with a hash for testing.
    @objc public static func creativeExperienceSettings(settingsHash: String?) -> CreativeExperienceSettings {
        return CreativeExperienceSettings(settingsHash: settingsHash,
                                          maxAdExperienceTime: 0.0,
                                          vastSkipThresholds: [],
                                          endCardDurations: EndCardDurations.defaultValue,
                                          mainAd: CreativeExperienceAdSettings.defaultValue,
                                          endCard: CreativeExperienceAdSettings.defaultValue)
    }
    
    /// Swift helper function to create a `CreativeExperienceSettings` object for testing.
    static func creativeExperienceSettings(settingsHash: String? = nil,
                                           maxAdExperienceTime: TimeInterval = 0.0,
                                           vastSkipThresholds: [VASTSkipThreshold] = [],
                                           endCardDurations: EndCardDurations = EndCardDurations.defaultValue,
                                           mainAd: CreativeExperienceAdSettings = CreativeExperienceAdSettings.defaultValue,
                                           endCard: CreativeExperienceAdSettings = CreativeExperienceAdSettings.defaultValue) -> CreativeExperienceSettings {
        return CreativeExperienceSettings(settingsHash: settingsHash,
                                          maxAdExperienceTime: maxAdExperienceTime,
                                          vastSkipThresholds: vastSkipThresholds,
                                          endCardDurations: endCardDurations,
                                          mainAd: mainAd,
                                          endCard: endCard)
    }
    
    
    /// Helper function to decode a Creative Experiences model object from `jsonString`.
    static func object<T: Decodable>(from jsonString: String, isRewarded: Bool = false) -> T? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.userInfo[CreativeExperienceSettings.isRewardedUserInfoKey] = isRewarded
        return try? decoder.decode(T.self, from: data)
    }
}
