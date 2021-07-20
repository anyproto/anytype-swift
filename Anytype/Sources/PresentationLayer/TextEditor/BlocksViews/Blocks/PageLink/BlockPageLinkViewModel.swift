
import UIKit
import Combine
import BlocksModels


struct BlockPageLinkViewModel: BlockViewModelProtocol {
    let isStruct = true
    
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
        
        if let details = details {
            state = BlockPageLinkState.Converter.asOurModel(details)
        } else {
            state = .empty
        }
    }
    
    func makeContentConfiguration() -> UIContentConfiguration {
        return BlockPageLinkContentConfiguration(content: content, state: state)
    }
    
    func didSelectRowInTableView() {
        openLink(content.targetBlockID)
    }
    
    func handle(action: ContextualMenuAction) {
        contextualMenuHandler.handle(action: action, info: information)
    }
    
    func makeContextualMenu() -> ContextualMenu {
        ContextualMenu(
            title: "",
            children: [
                .init(action: .addBlockBelow),
                .init(action: .duplicate),
                .init(action: .delete)
            ]
        )
    }
}
