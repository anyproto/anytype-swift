import UIKit

final class SlashMenuAssembly {
    let actionsHandler: SlashMenuActionsHandler
    
    init(actionsHandler: SlashMenuActionsHandler) {
        self.actionsHandler = actionsHandler
    }
    
    func menuController(
        menuItems: [BlockActionMenuItem],
        dismissHandler: (() -> Void)?
    ) -> SlashMenuViewController {
        let controller = SlashMenuViewController(
            cellData: menuItems.map { item in
                return .menu(item: item.item, actions: item.children)
            },
            actionsHandler: actionsHandler,
            dismissHandler: dismissHandler
        )
        
        return controller
    }
    
    func menuView(frame: CGRect, menuItems: [BlockActionMenuItem]) -> SlashMenuView {
        SlashMenuView(frame: frame, menuItems: menuItems, actionsHandler: actionsHandler)
    }
}
