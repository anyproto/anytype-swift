//
//  AnalyticsConfigurator.swift
//  Anytype
//
//  Created by Konstantin Mordan on 21.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import Amplitude

final class AnalyticsConfigurator: AppConfiguratorProtocol {

    func configure() {
        // Check analytics feature flag
        let isEnabled: Bool
        #if !RELEASE
        isEnabled = FeatureFlags.analytics
        #else
        isEnabled = true
        #endif
        
        guard isEnabled else { return }
        
        // Disable IDFA for Amplitude
        if let trackingOptions = AMPTrackingOptions().disableIDFA() {
            Amplitude.instance().setTrackingOptions(trackingOptions)
        }

        // Enable sending automatic session events
        Amplitude.instance().trackingSessionEvents = true
          // Initialize SDK
        Amplitude.instance().initializeApiKey(AmplitudeConfiguration.apiKey)
    }

}
