
import UIKit
import Combine
import BlocksModels


struct BlockLinkViewModel: BlockViewModelProtocol {
    var upperBlock: BlockModelProtocol?
    
    var hashable: AnyHashable {
        [
            indentationLevel,
            information,
            state
            
        ] as [AnyHashable]
    }
    
    let indentationLevel: Int
    let information: BlockInformation

    private let contextualMenuHandler: DefaultContextualMenuHandler
    private let state: BlockLinkState
    
    private let content: BlockLink
    private let openLink: (BlockId) -> ()


    init(
        indentationLevel: Int,
        information: BlockInformation,
        content: BlockLink,
        details: ObjectDetails?,
        contextualMenuHandler: DefaultContextualMenuHandler,
        openLink: @escaping (BlockId) -> ()
    ) {
        self.indentationLevel = indentationLevel
        self.information = information
        self.content = content
        self.contextualMenuHandler = contextualMenuHandler
        self.openLink = openLink
        self.state = details.flatMap { BlockLinkState(pageDetails: $0) } ?? .empty
    }
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        return BlockLinkContentConfiguration(state: state)
    }
    
    func didSelectRowInTableView() {
        if state.deleted || state.archived {
            return
        }
        
        openLink(content.targetBlockID)
    }
    
    func handle(action: ContextualMenu) {
        contextualMenuHandler.handle(action: action, info: information)
    }
    
    func makeContextualMenu() -> [ContextualMenu] {
        if state.deleted || state.archived {
            return [ .addBlockBelow, .delete ]
        } else {
            return [ .addBlockBelow, .duplicate, .delete ]
        }
    }
}
