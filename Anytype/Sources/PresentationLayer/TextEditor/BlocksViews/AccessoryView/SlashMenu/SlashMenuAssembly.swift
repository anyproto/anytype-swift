import UIKit

final class SlashMenuAssembly {
    let actionsHandler: SlashMenuViewModel
    
    init(actionsHandler: SlashMenuViewModel) {
        self.actionsHandler = actionsHandler
    }
    
    func menuController(
        menuItems: [SlashMenuItem],
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
    
    static func menuView(size: CGSize, viewModel: SlashMenuViewModel) -> SlashMenuView {
        SlashMenuView(frame: CGRect(origin: .zero, size: size), viewModel: viewModel)
    }
}
