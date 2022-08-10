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
    static var featureFlags: [String: Bool]
}
