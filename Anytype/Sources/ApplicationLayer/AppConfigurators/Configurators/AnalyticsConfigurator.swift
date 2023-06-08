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
            
        var attributes = EKAttributes.topFloat
        attributes.entryBackground = .color(color: EKColor(red: 169, green: 134, blue: 235))
        attributes.precedence = .enqueue(priority: .high)
        
        let titleText = "Event: \(eventType)"
        let title = EKProperty.LabelContent(text: titleText, style: .init(font: .systemFont(ofSize: 12), color: .white))
        
        let descriptionText = eventProperties?
            .sorted(by: { "\($0.key)" < "\($1.key)" })
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n") ?? ""
        let description = EKProperty.LabelContent(text: descriptionText, style: .init(font: .systemFont(ofSize: 12), color: .white))
        
        let simpleMessage = EKSimpleMessage(title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
}
