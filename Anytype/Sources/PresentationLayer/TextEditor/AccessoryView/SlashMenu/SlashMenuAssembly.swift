import UIKit

@MainActor
final class SlashMenuAssembly {
    static func menuController(
        cellData: [SlashMenuCellData] = [],
        topBarTitle: String? = nil,
        viewModel: SlashMenuViewModel,
        dismissHandler: (() -> Void)?
    ) -> SlashMenuViewController {
        return SlashMenuViewController(
            cellData: cellData,
            topBarTitle: topBarTitle,
            actionsHandler: viewModel,
            dismissHandler: dismissHandler
        )
    }
    
    static func menuView(size: CGSize, viewModel: SlashMenuViewModel) -> SlashMenuView {
        SlashMenuView(frame: CGRect(origin: .zero, size: size), viewModel: viewModel)
    }
}
