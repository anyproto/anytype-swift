import BlocksModels
import UIKit

struct DividerBlockViewModel: BlockViewModelProtocol {
    var isStruct = true
    
    let indentationLevel = 0
    let information: BlockInformation
    
    private let dividerContent: BlockDivider
    private let handler: DefaultContextualMenuHandler
    
    init(content: BlockDivider, information: BlockInformation, handler: DefaultContextualMenuHandler) {
        self.dividerContent = content
        self.information = information
        self.handler = handler
    }
    
    func makeContentConfiguration() -> UIContentConfiguration {
        return DividerBlockContentConfiguration(content: dividerContent)
    }
    
    func makeContextualMenu() -> ContextualMenu {
        .init(title: "", children: [
            .init(action: .addBlockBelow),
            .init(action: .delete),
            .init(action: .duplicate)
        ])
    }
    
    func handle(action: ContextualMenuAction) {
        handler.handle(action: action, info: information)
    }
    
    func didSelectRowInTableView() {}
    func updateView() {}
}
