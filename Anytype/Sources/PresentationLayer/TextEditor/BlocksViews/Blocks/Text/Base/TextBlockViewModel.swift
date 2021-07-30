import Combine
import UIKit
import BlocksModels


struct TextBlockViewModel: BlockViewModelProtocol {
    var indentationLevel: Int
    var information: BlockInformation
    private let block: BlockModelProtocol
    
    private let content: BlockText
    private let isCheckable: Bool
    private let toggled: Bool
    
    private let contextualMenuHandler: DefaultContextualMenuHandler
    private let blockDelegate: BlockDelegate
    private let configureMentions: (UITextView) -> Void
    private let showStyleMenu: (BlockInformation) -> Void
    private let actionHandler: EditorActionHandlerProtocol
    private let focusSubject = PassthroughSubject<BlockFocusPosition, Never>()
    
    var hashable: AnyHashable {
        [
            indentationLevel,
            information,
            isCheckable,
            toggled
        ] as [AnyHashable]
    }
    
    init(
        block: BlockModelProtocol,
        content: BlockText,
        isCheckable: Bool,
        contextualMenuHandler: DefaultContextualMenuHandler,
        blockDelegate: BlockDelegate,
        actionHandler: EditorActionHandlerProtocol,
        configureMentions: @escaping (UITextView) -> Void,
        showStyleMenu:  @escaping (BlockInformation) -> Void)
    {
        self.block = block
        self.content = content
        self.isCheckable = isCheckable
        self.contextualMenuHandler = contextualMenuHandler
        self.blockDelegate = blockDelegate
        self.actionHandler = actionHandler
        self.configureMentions = configureMentions
        self.showStyleMenu = showStyleMenu
        self.toggled = block.isToggled
        self.information = block.information
        self.indentationLevel = block.indentationLevel
    }
    
    func set(focus: BlockFocusPosition) {
        focusSubject.send(focus)
    }
    
    func didSelectRowInTableView() {}
    
    func makeContextualMenu() -> [ContextualMenu] {
        guard content.contentType != .title else {
            return [ .addBlockBelow ]
        }

        return [ .addBlockBelow, .turnIntoPage, .duplicate, .style, .delete ]
    }
    
    func handle(action: ContextualMenu) {
        contextualMenuHandler.handle(action: action, info: information)
    }
    
    func makeContentConfiguration() -> UIContentConfiguration {
        TextBlockContentConfiguration(
            blockDelegate: blockDelegate,
            block: block,
            isCheckable: isCheckable,
            actionHandler: actionHandler,
            configureMentions: configureMentions,
            showStyleMenu: showStyleMenu,
            focusPublisher: focusSubject.eraseToAnyPublisher())
    }
}
