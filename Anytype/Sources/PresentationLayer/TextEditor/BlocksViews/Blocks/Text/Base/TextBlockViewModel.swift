import Combine
import UIKit
import BlocksModels

struct TextBlockViewModel: BlockViewModelProtocol {
    
    let isStruct = true
    let block: BlockActiveRecordProtocol
    private let contextualMenuHandler: DefaultContextualMenuHandler
    private let blockDelegate: BlockDelegate
    private let mentionsConfigurator: MentionsTextViewConfigurator
    private let actionHandler: EditorActionHandlerProtocol
    private let focusSubject = PassthroughSubject<BlockFocusPosition, Never>()
    private let router: EditorRouterProtocol
    
    var indentationLevel: Int {
        block.indentationLevel
    }
    
    var diffable: AnyHashable {
        [blockId,
         indentationLevel,
         block.isToggled,
         block.blockModel.information.content
        ] as [AnyHashable]
    }
    
    var information: BlockInformation {
        block.blockModel.information
    }
    
    init(block: BlockActiveRecordProtocol,
         contextualMenuHandler: DefaultContextualMenuHandler,
         blockDelegate: BlockDelegate,
         mentionsConfigurator: MentionsTextViewConfigurator,
         actionHandler: EditorActionHandlerProtocol,
         router: EditorRouterProtocol) {
        self.block = block
        self.contextualMenuHandler = contextualMenuHandler
        self.blockDelegate = blockDelegate
        self.mentionsConfigurator = mentionsConfigurator
        self.actionHandler = actionHandler
        self.router = router
    }
    
    func set(focus: BlockFocusPosition) {
        focusSubject.send(focus)
    }
    
    func didSelectRowInTableView() {}
    
    func updateView() {}
    
    func makeContextualMenu() -> ContextualMenu {
        guard case let .text(text) = block.content else {
            return .init(title: "", children: [])
        }
        
        let actions: [ContextualMenuData] = {
            var result: [ContextualMenuData] = [
                .init(action: .addBlockBelow)
            ]
            
            guard text.contentType != .title else { return result }
            
            result.append(
                contentsOf: [
                    .init(action: .turnIntoPage),
                    .init(action: .delete),
                    .init(action: .duplicate),
                    .init(action: .style)
                ]
            )
            
            return result
        }()
        
        
        return .init(title: "", children: actions)
    }
    
    func handle(action: ContextualMenuAction) {
        contextualMenuHandler.handle(action: action, info: information)
    }
    
    func makeContentConfiguration() -> UIContentConfiguration {
        TextBlockContentConfiguration(blockDelegate: blockDelegate,
                                       block: block,
                                       mentionsConfigurator: mentionsConfigurator,
                                       actionHandler: actionHandler,
                                       focusPublisher: focusSubject.eraseToAnyPublisher(),
                                       editorRouter: router)
    }
}
