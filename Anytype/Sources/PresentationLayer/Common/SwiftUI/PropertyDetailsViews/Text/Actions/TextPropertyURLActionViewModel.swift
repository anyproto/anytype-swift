import Foundation
import UIKit
import AnytypeCore

@MainActor
final class TextPropertyURLActionViewModel: TextPropertyActionViewModelProtocol {
    
    enum SupportedTextType {
        case phone
        case email
        case url
    }
    
    @Injected(\.systemURLService)
    private var systemURLService: any SystemURLServiceProtocol
    
    private let type: SupportedTextType
    private weak var delegate: (any TextPropertyActionButtonViewModelDelegate)?
    
    let id = UUID().uuidString
    var inputText: String = ""
    var title: String { type.title }
    var iconAsset: ImageAsset { type.iconAsset }
    
    init(
        type: SupportedTextType,
        delegate: (any TextPropertyActionButtonViewModelDelegate)?
    ) {
        self.type = type
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
        logEvent()
    }
    
    private var urlToOpen: URL? {
        switch type {
        case .phone: return systemURLService.buildPhoneUrl(phone: inputText)
        case .email: return systemURLService.buildEmailUrl(to: inputText)
        case .url: return AnytypeURL(string: inputText)?.url
        }
    }
    
    private func logEvent() {
        switch type {
        case .phone, .email:
            break
        case .url:
            AnytypeAnalytics.instance().logRelationUrlOpen()
        }
    }
}

private extension TextPropertyURLActionViewModel.SupportedTextType {
    var iconAsset: ImageAsset {
        switch self {
        case .phone: return .X24.phoneNumber
        case .email: return .X24.email
        case .url: return  .X24.open
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
