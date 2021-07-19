import BlocksModels
import UIKit

struct DividerBlockViewModel: BlockViewModelProtocol {
    let isStruct = true
    
    var diffable: AnyHashable {
        [
            blockId,
            dividerContent,
            indentationLevel
        ] as [AnyHashable]
    }
    
    let indentationLevel: Int
    let information: BlockInformation
    
    private let dividerContent: BlockDivider
    private let handler: DefaultContextualMenuHandler
    
    init(content: BlockDivider, information: BlockInformation, indentationLevel: Int, handler: DefaultContextualMenuHandler) {
        self.dividerContent = content
        self.information = information
        self.indentationLevel = indentationLevel
        self.handler = handler
    }
    
    func makeContentConfiguration() -> UIContentConfiguration {
        return DividerBlockContentConfiguration(content: dividerContent)
    }
    
    func makeContextualMenu() -> ContextualMenu {
        .init(title: "", children: [
            .init(action: .addBlockBelow),
            .init(action: .duplicate),
            .init(action: .delete)
        ])
    }
    
    func handle(action: ContextualMenuAction) {
        handler.handle(action: action, info: information)
    }
    
    func didSelectRowInTableView() {}
}
