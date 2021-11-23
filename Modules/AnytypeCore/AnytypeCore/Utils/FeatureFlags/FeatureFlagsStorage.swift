//
//  FeatureFlagsStorage.swift
//  AnytypeCore
//
//  Created by Denis Batvinkin on 23.11.2021.
//

/// User defaults store
public struct FeatureFlagsStorage {
    // MARK: - Feature flags
    @UserDefault("FeatureFlags", defaultValue: [:])
    private static var encodedFeatureFlags: [String: Bool]

    static var featureFlags: [Feature: Bool] {
        get {
            Dictionary(uniqueKeysWithValues: encodedFeatureFlags.compactMap { (key, value) in
                guard let feature = Feature(rawValue: key) else {
                    return nil
                }

                return (feature, value)
            })
        }
        set {
            encodedFeatureFlags = Dictionary(uniqueKeysWithValues: newValue.map {
                key, value in (key.rawValue, value)
            })
        }
    }
}
