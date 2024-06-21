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
        if configuration.contentType == .text(.title) || configuration.contentType == .text(.description) {
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
