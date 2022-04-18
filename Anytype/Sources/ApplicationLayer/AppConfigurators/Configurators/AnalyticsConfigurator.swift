import UIKit
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
        
          // Initialize SDK
        #if !RELEASE
        AnytypeAnalytics.instance().initializeApiKey(AnalyticsConfiguration.devAPIKey)
        #else
        AnytypeAnalytics.instance().initializeApiKey(AnalyticsConfiguration.prodAPIKey)
        #endif
    }

}
