import UIKit
import BlocksModels

struct AccessoryViewSwitcherBuilder {
    func accessoryViewSwitcher(
        actionHandler: EditorActionHandlerProtocol,
        router: EditorRouter
    ) -> AccessoryViewSwitcher {
        let mentionsView = MentionView(frame: CGRect(origin: .zero, size: menuActionsViewSize))
        
        let accessoryViewModel = EditorAccessoryViewModel(router: router)
        let accessoryView = EditorAccessoryView(viewModel: accessoryViewModel)
        
        let slashHandler = SlashMenuActionsHandlerImp(actionHandler: actionHandler)
        let slashMenuView = SlashMenuAssembly.menuView(
            size: menuActionsViewSize,
            actionsHandler: slashHandler
        )

        let accessoryViewSwitcher = AccessoryViewSwitcher(
            mentionsView: mentionsView,
            slashMenuView: slashMenuView,
            accessoryView: accessoryView,
            handler: actionHandler
        )
        
        mentionsView.delegate = accessoryViewSwitcher
        accessoryViewModel.delegate = accessoryViewSwitcher
        
        return accessoryViewSwitcher
    }
    
    private let menuActionsViewSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.isFourInch ? 160 : 215
    )
}
