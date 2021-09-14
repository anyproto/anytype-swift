import UIKit
import BlocksModels

final class AccessoryViewSwitcherBuilder {
    private let actionHandler: EditorActionHandlerProtocol
    
    init(actionHandler: EditorActionHandlerProtocol) {
        self.actionHandler = actionHandler
    }
    
    func accessoryViewSwitcher(
        delegate: TextViewDelegate & AccessoryViewSwitcherDelegate
    ) -> AccessoryViewSwitcher {
        let mentionsView = MentionView(frame: CGRect(origin: .zero, size: menuActionsViewSize))
        
        let accessoryHandler = EditorAccessoryViewActionHandler(delegate: delegate)
        let accessoryView = EditorAccessoryView(actionHandler: accessoryHandler)
        
        let slashHandler = SlashMenuActionsHandlerImp(actionHandler: actionHandler)
        let slashMenuView = SlashMenuAssembly.menuView(
            size: menuActionsViewSize,
            actionsHandler: slashHandler
        )

        let accessoryViewSwitcher = AccessoryViewSwitcher(
            delegate: delegate,
            mentionsView: mentionsView,
            slashMenuView: slashMenuView,
            accessoryView: accessoryView
        )
        
        mentionsView.delegate = accessoryViewSwitcher
        accessoryHandler.switcher = accessoryViewSwitcher
        
        return accessoryViewSwitcher
    }
    
    private let menuActionsViewSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.isFourInch ? 160 : 215
    )
}
