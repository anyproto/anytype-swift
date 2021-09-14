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
    
    static func menuView(size: CGSize, actionsHandler: SlashMenuActionsHandler) -> SlashMenuView {
        SlashMenuView(frame: CGRect(origin: .zero, size: size), actionsHandler: actionsHandler)
    }
}
