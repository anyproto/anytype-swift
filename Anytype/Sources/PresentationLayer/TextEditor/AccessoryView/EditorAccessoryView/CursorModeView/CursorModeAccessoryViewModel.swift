import UIKit
import Services
import AnytypeCore
import Combine

enum CursorModeAccessoryViewAction {
    /// Slash button pressed
    case slashMenu
    /// Done button pressed
    case keyboardDismiss
    /// Show bottom sheet style menu
    case showStyleMenu
    /// Show mention menu
    case mention
    /// Enter editing mode
    case editingMode
}


final class CursorModeAccessoryViewModel {
    @Published var items = [CursorModeAccessoryView.Item]()
    
    var onActionHandler: ((CursorModeAccessoryViewAction) -> Void)?
    
    func update(with configuration: TextViewAccessoryConfiguration) {
        let actions: [CursorModeAccessoryView.Item]
        if configuration.contentType == .text(.title) {
            actions = [.style]
        } else {
            switch configuration.usecase {
            case .editor:
                actions = [.slash, .style, .actions, .mention]
            case .simpleTable:
                actions = [.style, .actions, .mention]
            }
        }
        
        self.items = actions
    }
    
    func handle(_ action: CursorModeAccessoryViewAction) {
        onActionHandler?(action)
    }
}

// MARK: - Analytics
extension CursorModeAccessoryViewAction {
    typealias AnalyticsConstants = AnalyticsEventsName.KeyboardBarAction
    var analyticsEvent: String {
        switch self {
        case .slashMenu:
            return AnalyticsConstants.slashMenu
        case .keyboardDismiss:
            return AnalyticsConstants.hideKeyboard
        case .showStyleMenu:
            return AnalyticsConstants.styleMenu
        case .mention:
            return AnalyticsConstants.mentionMenu
        case .editingMode:
            return AnalyticsConstants.selectionMenu
        }
    }
}
