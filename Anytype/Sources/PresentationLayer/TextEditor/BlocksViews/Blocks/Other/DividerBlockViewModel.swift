import BlocksModels
import UIKit

class DividerBlockViewModel: BaseBlockViewModel {
    private let dividerContent: BlockDivider
    
    init(
        _ block: BlockActiveRecordProtocol,
        content: BlockDivider,
        delegate: BlockDelegate?,
        actionHandler: EditorActionHandlerProtocol,
        router: EditorRouterProtocol
    ) {
        self.dividerContent = content
        super.init(block, delegate: delegate, actionHandler: actionHandler, router: router)
    }
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        return DividerBlockContentConfiguration(content: dividerContent)
    }
    
    override var diffable: AnyHashable {
        let newDiffable: [String: AnyHashable] = [
            "parent": super.diffable,
            "dividerValue": dividerContent.style
        ]
        return .init(newDiffable)
    }
    
    // MARK: Contextual Menu
    override func makeContextualMenu() -> ContextualMenu {
        .init(title: "", children: [
            .init(action: .addBlockBelow),
            .init(action: .delete),
            .init(action: .duplicate)
        ])
    }
}
