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
    /// Enter editing mode
    case editingMode
    /// Show undo / redo mode
    case undoRedo
}


final class CursorModeAccessoryViewModel {
    @Published var items = [CursorModeAccessoryView.Item]()
    
    var onActionHandler: ((CursorModeAccessoryViewAction) -> Void)?
    
    func update(with configuration: TextViewAccessoryConfiguration) {
        var actions: [CursorModeAccessoryView.Item]
        if configuration.contentType == .text(.title) || configuration.contentType == .text(.description) {
            actions = [.style]
        } else {
            switch configuration.usecase {
            case .editor:
                actions = [.slash, .style, .actions, .undoRedo]
            case .simpleTable:
                actions = [.style, .actions, .undoRedo]
            }
        }
        
        self.items = actions
    }
    
    func handle(_ action: CursorModeAccessoryViewAction) {
        onActionHandler?(action)
    }
}
