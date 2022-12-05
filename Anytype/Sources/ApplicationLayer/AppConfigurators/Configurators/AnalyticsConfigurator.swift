import UIKit
import AnytypeCore

final class AnalyticsConfigurator: AppConfiguratorProtocol {

    func configure() {
        // Check analytics feature flag
        #if DEBUG
        AnytypeAnalytics.instance().isEnabled = FeatureFlags.analytics
        #endif

        AnytypeAnalytics.instance().setEventConfiguartion(event: AnalyticsEventsName.blockSetTextText,
                                                          configuation: .init(threshold: .notInRow))
        
          // Initialize SDK
        #if DEBUG
        AnytypeAnalytics.instance().initializeApiKey(AnalyticsConfiguration.devAPIKey)
        #else
        AnytypeAnalytics.instance().initializeApiKey(AnalyticsConfiguration.prodAPIKey)
        #endif
    }

}
