import Foundation
import UIKit

final class TextPropertyCopyActionViewModel: TextPropertyActionViewModelProtocol {
    
    enum SupportedTextType {
        case phone
        case email
        case url
    }
    
    private let type: SupportedTextType
    private weak var delegate: (any TextPropertyActionButtonViewModelDelegate)?
    
    let id = UUID().uuidString
    var inputText: String = ""
    var title: String { type.title }
    let iconAsset = ImageAsset.X24.copy
    
    init(
        type: SupportedTextType,
        delegate: (any TextPropertyActionButtonViewModelDelegate)?
    ) {
        self.type = type
        self.delegate = delegate
    }
    
    var isActionAvailable: Bool {
        return inputText.isNotEmpty
    }
    
    func performAction() {
        UISelectionFeedbackGenerator().selectionChanged()
        UIPasteboard.general.string = inputText
        delegate?.showActionSuccessMessage(Loc.RelationAction.copied)
        logEvent()
    }
    
    private func logEvent() {
        switch type {
        case .phone, .email:
            break
        case .url:
            AnytypeAnalytics.instance().logRelationUrlCopy()
        }
    }
}

private extension TextPropertyCopyActionViewModel.SupportedTextType {
    var title: String {
        switch self {
        case .phone: return Loc.RelationAction.copyPhone
        case .email: return Loc.RelationAction.copyEmail
        case .url: return Loc.RelationAction.copyLink
        }
    }
}
