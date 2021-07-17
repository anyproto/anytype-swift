import Combine
import UIKit
import BlocksModels

struct TextBlockViewModel: BlockViewModelProtocol {
    
    let isStruct = true
    let block: BlockActiveRecordProtocol
    private let toggled: Bool
    private let contextualMenuHandler: DefaultContextualMenuHandler
    private let blockDelegate: BlockDelegate
    private let configureMentions: (UITextView) -> Void
    private let showStyleMenu: (BlockInformation) -> Void
    private let actionHandler: EditorActionHandlerProtocol
    private let focusSubject = PassthroughSubject<BlockFocusPosition, Never>()
    
    var indentationLevel: Int {
        block.indentationLevel
    }
    
    var diffable: AnyHashable {
        [blockId,
         indentationLevel,
         toggled,
         block.blockModel.information.content
        ] as [AnyHashable]
    }
    
    var information: BlockInformation {
        block.blockModel.information
    }
    
    init(block: BlockActiveRecordProtocol,
         contextualMenuHandler: DefaultContextualMenuHandler,
         blockDelegate: BlockDelegate,
         actionHandler: EditorActionHandlerProtocol,
         configureMentions: @escaping (UITextView) -> Void,
         showStyleMenu:  @escaping (BlockInformation) -> Void) {
        self.block = block
        self.contextualMenuHandler = contextualMenuHandler
        self.blockDelegate = blockDelegate
        self.actionHandler = actionHandler
        self.configureMentions = configureMentions
        self.showStyleMenu = showStyleMenu
        toggled = block.isToggled
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
                    .init(action: .duplicate),
                    .init(action: .style),
                    .init(action: .delete)
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
        TextBlockContentConfiguration(
            blockDelegate: blockDelegate,
            block: block,
            actionHandler: actionHandler,
            configureMentions: configureMentions,
            showStyleMenu: showStyleMenu,
            focusPublisher: focusSubject.eraseToAnyPublisher())
    }
}
