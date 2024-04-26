import Foundation
import UIKit

final class TextRelationCopyActionViewModel: TextRelationActionViewModelProtocol {
    
    enum SupportedTextType {
        case phone
        case email
        case url
    }
    
    private let type: SupportedTextType
    private let alertOpener: AlertOpenerProtocol
    private weak var delegate: TextRelationActionButtonViewModelDelegate?
    
    var inputText: String = ""
    var title: String { type.title }
    let iconAsset = ImageAsset.X24.copy
    
    init(
        type: SupportedTextType,
        alertOpener: AlertOpenerProtocol,
        delegate: TextRelationActionButtonViewModelDelegate?
    ) {
        self.type = type
        self.alertOpener = alertOpener
        self.delegate = delegate
    }
    
    var isActionAvailable: Bool {
        return inputText.isNotEmpty
    }
    
    func performAction() {
        UISelectionFeedbackGenerator().selectionChanged()
        UIPasteboard.general.string = inputText
        alertOpener.showTopAlert(message: Loc.RelationAction.copied)
        logEvent()
    }
    
    private func logEvent() {
        switch type {
        case .phone, .email:
            break
        case .url:
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.relationUrlCopy)
        }
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
}
