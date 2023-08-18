import Foundation
import SwiftEntryKit

extension SwiftEntryKit {
    static func displayDebugInfo(title: String, description: String) {
        DispatchQueue.main.async {
            var attributes = EKAttributes.topFloat
            attributes.entryBackground = .color(color: EKColor(red: 169, green: 134, blue: 235))
            attributes.precedence = .enqueue(priority: .high)
            
            let titleContent = EKProperty.LabelContent(text: title, style: .init(font: .systemFont(ofSize: 12), color: .white))
            let descriptionContent = EKProperty.LabelContent(text: description, style: .init(font: .systemFont(ofSize: 12), color: .white))
            
            let simpleMessage = EKSimpleMessage(title: titleContent, description: descriptionContent)
            let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
            let contentView = EKNotificationMessageView(with: notificationMessage)
            SwiftEntryKit.display(entry: contentView, using: attributes)
        }
    }
    
    static func displayDebugError(title: String, description: String) {
        DispatchQueue.main.async {
            var attributes = EKAttributes.topFloat
            attributes.entryBackground = .color(color: EKColor(red: 255, green: 0, blue: 64))
            attributes.precedence = .enqueue(priority: .high)
            
            let titleContent = EKProperty.LabelContent(text: title, style: .init(font: .systemFont(ofSize: 12), color: .white))
            let descriptionContent = EKProperty.LabelContent(text: description, style: .init(font: .systemFont(ofSize: 12), color: .white))
            
            let simpleMessage = EKSimpleMessage(title: titleContent, description: descriptionContent)
            let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
            let contentView = EKNotificationMessageView(with: notificationMessage)
            SwiftEntryKit.display(entry: contentView, using: attributes)
        }
    }
}
