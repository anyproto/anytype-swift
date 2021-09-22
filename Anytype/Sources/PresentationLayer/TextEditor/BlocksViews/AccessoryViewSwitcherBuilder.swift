import UIKit
import BlocksModels

struct AccessoryViewSwitcherBuilder {
    func accessoryViewSwitcher(
        actionHandler: EditorActionHandlerProtocol,
        router: EditorRouter
    ) -> AccessoryViewSwitcher {
        let mentionsView = MentionView(frame: CGRect(origin: .zero, size: menuActionsViewSize))
        
        let accessoryViewModel = EditorAccessoryViewModel(router: router, handler: actionHandler)
        let accessoryView = EditorAccessoryView(viewModel: accessoryViewModel)
        
        let slashMenuViewModel = SlashMenuViewModel(actionHandler: actionHandler)
        let slashMenuView = SlashMenuAssembly.menuView(
            size: menuActionsViewSize,
            viewModel: slashMenuViewModel
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
