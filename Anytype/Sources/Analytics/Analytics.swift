//
//  Analytics.swift
//  Anytype
//
//  Created by Denis Batvinkin on 19.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Amplitude


// Helper methos for analytics
class Analytics {
    /// Setup analytics
    static func setupAnalytics() {
        // Disable IDFA for Amplitude
        if let trackingOptions = AMPTrackingOptions().disableIDFA() {
            Amplitude.instance().setTrackingOptions(trackingOptions)
        }

        // Enable sending automatic session events
        Amplitude.instance().trackingSessionEvents = true
        // Initialize SDK
        Amplitude.instance().initializeApiKey(AmplitudeConfiguration.apiKey)
        // Check analytics feature flag
        #if !RELEASE
        Analytics.isEnabled = FeatureFlags.analytics
        #endif
    }

    /// Set `true` to send analytics otherwise `false`
    static var isEnabled: Bool {
        set {
            Amplitude.instance().optOut = !newValue
        }
        get {
            return !Amplitude.instance().optOut
        }
    }
}

