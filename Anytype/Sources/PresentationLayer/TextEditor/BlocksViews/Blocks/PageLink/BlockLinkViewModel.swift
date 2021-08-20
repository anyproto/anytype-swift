
import UIKit
import Combine
import BlocksModels


struct BlockLinkViewModel: BlockViewModelProtocol {
    var hashable: AnyHashable {
        [
            indentationLevel,
            information
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
        details: DetailsData?,
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
        if ObjectTypeProvider.isSupported(type: state.type) {
            openLink(content.targetBlockID)
            return
        }
        
        showNotSupportedAlert()
    }
    
    func showNotSupportedAlert() {
        let typeName = state.type?.name ?? ""
        let alert = UIAlertController(
            title: "Not supported type \"\(typeName)\"",
            message: "You can open it via desktop",
            preferredStyle: .actionSheet
        )
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2){
          alert.dismiss(animated: true, completion: nil)
        }
        
        windowHolder?.presentOnTop(alert, animated: true)
    }
    
    func handle(action: ContextualMenu) {
        contextualMenuHandler.handle(action: action, info: information)
    }
    
    func makeContextualMenu() -> [ContextualMenu] {
        [ .addBlockBelow, .duplicate, .delete ]
    }
}
