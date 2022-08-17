import Foundation
import UIKit

final class TextRelationURLActionViewModel: TextRelationActionViewModelProtocol {
    
    enum SupportedTextType {
        case phone
        case email
        case url
    }
    
    private let type: SupportedTextType
    private let systemURLService: SystemURLServiceProtocol
    private weak var delegate: TextRelationActionButtonViewModelDelegate?
    
    var inputText: String = ""
    var title: String { type.title }
    var iconAsset: ImageAsset { type.iconAsset }
    
    init(
        type: SupportedTextType,
        systemURLService: SystemURLServiceProtocol,
        delegate: TextRelationActionButtonViewModelDelegate?
    ) {
        self.type = type
        self.systemURLService = systemURLService
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
            return inputText.isValidPhone()
        case .email:
            return inputText.isValidEmail()
        case .url:
            return inputText.isValidURL()
        }
    }
    
    func performAction() {
        guard let url = urlToOpen else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        delegate?.openUrl(url)
    }
    
    private var urlToOpen: URL? {
        switch type {
        case .phone: return systemURLService.buildPhoneUrl(phone: inputText)
        case .email: return systemURLService.buildEmailUrl(to: inputText)
        case .url: return URL(string: inputText)
        }
    }
}

private extension TextRelationURLActionViewModel.SupportedTextType {
    var iconAsset: ImageAsset {
        switch self {
        case .phone: return .relationSmallPhoneIcon
        case .email: return .relationSmallEmailIcon
        case .url: return  .relationSmallOpenLink
        }
    }
    
    var title: String {
        switch self {
        case .phone: return Loc.RelationAction.callPhone
        case .email: return Loc.RelationAction.sendEmail
        case .url: return Loc.RelationAction.openLink
        }
    }
}
