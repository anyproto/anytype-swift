//
//  FeatureFlagsStorage.swift
//  AnytypeCore
//
//  Created by Denis Batvinkin on 23.11.2021.
//

/// User defaults store
public struct FeatureFlagsStorage: Sendable {
    // MARK: - Feature flags
    private static let storage = UserDefaultStorage(key: "FeatureFlags", defaultValue: [String: Bool]())
    static var featureFlags: [String: Bool] {
        get { storage.value }
        set { storage.value = newValue }
    }
}
