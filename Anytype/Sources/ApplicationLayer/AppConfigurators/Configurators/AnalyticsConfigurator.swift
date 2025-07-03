import UIKit
import AnytypeCore
import SwiftEntryKit
import Logger

final class AnalyticsConfigurator: AppConfiguratorProtocol, Sendable {

    func configure() {
        // Check analytics feature flag
        #if DEBUG || RELEASE_NIGHTLY
        
        AnytypeAnalytics.instance().setIsEnabled(FeatureFlags.analytics)
        
        #endif
        
        AnytypeAnalytics.instance().setEventHandler({ [weak self] eventType, eventProperties in
            self?.log(eventType: eventType, eventProperties: eventProperties)
        })
        
        AnytypeAnalytics.instance().setEventConfiguartion(event: AnalyticsConfiguration.blockEvent,
                                                          configuation: .init(threshold: .notInRow))
        
        // Initialize SDK
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: AnalyticsConfiguration.apiKey) as? String,
              apiKey.isNotEmpty else {
            AnytypeAnalytics.instance().setIsEnabled(false)
            return
        }
        
        AnytypeAnalytics.instance().initializeApiKey(apiKey)
    }
    
    private func log(eventType: String, eventProperties: [AnyHashable : Any]?) {
        
        // Log
        #if DEBUG || RELEASE_NIGHTLY
        
        let info = eventProperties.map { Dictionary(uniqueKeysWithValues: $0.map { key, value in ("\(key)", "\(value)") } ) }
        AnalyticsLogger.shared.log(eventType, info: info)
        
        #endif
        
        // Show alert
        
        guard FeatureFlags.analyticsAlerts else { return }
        
        let title = "Event: \(eventType)"
        
        let description = eventProperties?
            .sorted(by: { "\($0.key)" < "\($1.key)" })
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n") ?? ""

        SwiftEntryKit.displayDebugInfo(title: title, description: description)
    }
}
