import Foundation
import UIKit

final class TextRelationCopyActionViewModel: TextRelationActionViewModelProtocol {
    
    enum SupportedTextType {
        case phone
        case email
        case url
    }
    
    private let type: SupportedTextType
    private weak var delegate: TextRelationActionButtonViewModelDelegate?
    
    var inputText: String = ""
    var title: String { type.title }
    let iconAsset = ImageAsset.relationSmallCopy
    
    init(type: SupportedTextType, delegate: TextRelationActionButtonViewModelDelegate?) {
        self.type = type
        self.delegate = delegate
    }
    
    var isActionAvailable: Bool {
        true
    }
    
    func performAction() {
        UISelectionFeedbackGenerator().selectionChanged()
        UIPasteboard.general.string = inputText
    }
}

private extension TextRelationCopyActionViewModel.SupportedTextType {
    var title: String {
        switch self {
        case .phone: return Loc.RelationAction.copyPhone
        case .email: return Loc.RelationAction.copyEmail
        case .url: return Loc.RelationAction.copyLink
        }
    }
    
    var confirmText: String {
        switch self {
        case .phone: return Loc.RelationAction.phoneCopied
        case .email: return Loc.RelationAction.emailCopied
        case .url: return Loc.RelationAction.linkCopied
        }
    }
}
