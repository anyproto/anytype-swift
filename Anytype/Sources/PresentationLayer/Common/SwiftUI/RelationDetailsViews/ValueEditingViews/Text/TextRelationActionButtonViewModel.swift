import Foundation
import UIKit

final class TextRelationActionButtonViewModel {
    
    var text: String = ""
    
    var icon: UIImage { type.icon }
    
    private let type: SupportedTextType
    
    // MARK: - Initializers
    
    init?(type: TextRelationEditingViewType) {
        guard let supportedType = SupportedTextType(type: type) else {
            return nil
        }
        
        self.type = supportedType
    }
    
    var isActionAvailable: Bool {
        switch type {
        case .phone:
            return text.isValidPhone()
        case .email:
            return text.isValidEmail()
        case .url:
            return text.isValidURL()
        }
    }
    
    func performAction() {
        
    }
    
}

private extension TextRelationActionButtonViewModel {
    
    enum SupportedTextType {
        case phone
        case email
        case url
        
        init?(type: TextRelationEditingViewType) {
            switch type {
            case .text, .number:
                return nil
            case .phone:
                self = .phone
            case .email:
                self = .email
            case .url:
                self = .url
            }
        }
    }
    
}

private extension TextRelationActionButtonViewModel.SupportedTextType {
    
    var icon: UIImage {
        switch self {
        case .phone: return UIImage.Relations.Icons.phone
        case .email: return UIImage.Relations.Icons.email
        case .url: return UIImage.Relations.Icons.goToURL
        }
    }
    
}
