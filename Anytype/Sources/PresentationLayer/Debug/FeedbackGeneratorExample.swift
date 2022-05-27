import Foundation
import UIKit

enum FeedbackGeneratorExample: Hashable {
    case notification(UINotificationFeedbackGenerator.FeedbackType)
    case selection
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
}

extension FeedbackGeneratorExample: Identifiable {
    
    var id: Self { self }
    
}

extension FeedbackGeneratorExample {
    
    var title: String {
        switch self {
        case .notification(let style): return style.title
        case .selection: return "Selection"
        case .impact(let style): return style.title
        }
    }
    
}

// MARK: - UIImpactFeedbackGenerator FeedbackStyle

extension UIImpactFeedbackGenerator.FeedbackStyle {
    
    static var feedbackTypes: [UIImpactFeedbackGenerator.FeedbackStyle] {
        [.light, .medium, .heavy, .soft, .rigid]
    }
    
    var title: String {
        switch self {
        case .light: return "Light"
        case .medium: return "Medium"
        case .heavy: return "Heavy"
        case .soft: return "Soft"
        case .rigid: return "Rigid"
        @unknown default: return "Unknown"  
        }
    }
    
}

// MARK: - UINotificationFeedbackGenerator FeedbackType

extension UINotificationFeedbackGenerator.FeedbackType {
    
    static var feedbackTypes: [UINotificationFeedbackGenerator.FeedbackType] {
        [.success, .warning, .error]
    }
    
    var title: String {
        switch self {
        case .success: return "Success"
        case .warning: return "Warning"
        case .error: return "Error"
        @unknown default: return "Unknown"
        }
    }
    
}
