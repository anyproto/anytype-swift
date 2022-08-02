import Foundation

final class TextRelationActionButtonViewModel {
    
    var text: String = ""
    
    var iconAsset: ImageAsset { type.iconAsset }
    
    private let type: SupportedTextType
    
    private weak var delegate: TextRelationActionButtonViewModelDelegate?
    
    // MARK: - Initializers
    
    init?(type: TextRelationDetailsViewType, delegate: TextRelationActionButtonViewModelDelegate?) {
        guard let supportedType = SupportedTextType(type: type) else {
            return nil
        }
        
        self.type = supportedType
        self.delegate = delegate
    }
    
    var isActionAvailable: Bool {
        guard
            let url = urlToOpen,
            let delegate = delegate,
            delegate.canOpenUrl(url)
        else { return false }
        
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
        guard let url = urlToOpen else { return }
        
        delegate?.openUrl(url)
    }
    
    private var urlToOpen: URL? {
        switch type {
        case .phone: return URL(string: "tel:\(text)")
        case .email: return URL(string: "mailto:\(text)")
        case .url: return URL(string: text)
        }
    }
    
}

private extension TextRelationActionButtonViewModel {
    
    enum SupportedTextType {
        case phone
        case email
        case url
        
        init?(type: TextRelationDetailsViewType) {
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
    
    var iconAsset: ImageAsset {
        switch self {
        case .phone: return .relationSmallPhoneIcon
        case .email: return .relationSmallEmailIcon
        case .url: return  .relationSmallGoToUrlIcon
        }
    }
    
}
