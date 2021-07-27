import UIKit
import Amplitude
import AnytypeCore

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
