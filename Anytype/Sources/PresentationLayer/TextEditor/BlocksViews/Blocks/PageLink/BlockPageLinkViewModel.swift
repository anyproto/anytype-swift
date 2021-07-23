
import UIKit
import Combine
import BlocksModels


struct BlockPageLinkViewModel: BlockViewModelProtocol {    
    var diffable: AnyHashable {
        [
            blockId,
            state,
            indentationLevel,
            content
        ] as [AnyHashable]
    }
    
    let indentationLevel: Int
    let information: BlockInformation

    private let contextualMenuHandler: DefaultContextualMenuHandler
    private let state: BlockPageLinkState
    
    private let content: BlockLink
    private let openLink: (BlockId) -> ()


    init(
        indentationLevel: Int,
        information: BlockInformation,
        content: BlockLink,
        details: DetailsData?,
        contextualMenuHandler: DefaultContextualMenuHandler,
        openLink: @escaping (BlockId) -> ()
    ) {
        self.indentationLevel = indentationLevel
        self.information = information
        self.content = content
        self.contextualMenuHandler = contextualMenuHandler
        self.openLink = openLink
        self.state = details.flatMap { BlockPageLinkState(pageDetails: $0) } ?? .empty
    }
    
    func makeContentConfiguration() -> UIContentConfiguration {
        return BlockPageLinkContentConfiguration(content: content, state: state)
    }
    
    func didSelectRowInTableView() {
        openLink(content.targetBlockID)
    }
    
    func handle(action: ContextualMenu) {
        contextualMenuHandler.handle(action: action, info: information)
    }
    
    func makeContextualMenu() -> [ContextualMenu] {
        [ .addBlockBelow, .duplicate, .delete ]
    }
}
