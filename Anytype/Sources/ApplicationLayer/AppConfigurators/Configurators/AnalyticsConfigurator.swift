import UIKit
import AnytypeCore
import SwiftEntryKit
import Logger

final class AnalyticsConfigurator: AppConfiguratorProtocol {

    func configure() {
        // Check analytics feature flag
        #if DEBUG
        AnytypeAnalytics.instance().isEnabled = FeatureFlags.analytics
        
        AnytypeAnalytics.instance().eventHandler = { [weak self] eventType, eventProperties in
            DispatchQueue.main.async {
                self?.log(eventType: eventType, eventProperties: eventProperties)
            }
        }
        #endif
        
        AnytypeAnalytics.instance().setEventConfiguartion(event: AnalyticsEventsName.blockSetTextText,
                                                          configuation: .init(threshold: .notInRow))
        
        // Initialize SDK
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: AnalyticsConfiguration.apiKey) as? String,
              apiKey.isNotEmpty else { return }
        
        AnytypeAnalytics.instance().initializeApiKey(apiKey)
    }
    
    private func log(eventType: String, eventProperties: [AnyHashable : Any]?) {
        
        // Log
        
        let info = eventProperties.map { Dictionary(uniqueKeysWithValues: $0.map { key, value in ("\(key)", "\(value)") } ) }
        AnalyticsLogger.shared.log(eventType, info: info)
        
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
