import Combine
import UIKit
import BlocksModels


struct TextBlockViewModel: BlockViewModelProtocol {
    var upperBlock: BlockModelProtocol?

    var indentationLevel: Int
    var information: BlockInformation

    private let block: BlockModelProtocol
    private let text: UIKitAnytypeText
    private let content: BlockText
    private let isCheckable: Bool
    private let toggled: Bool
    
    private let contextualMenuHandler: DefaultContextualMenuHandler
    private let blockDelegate: BlockDelegate
    private let showPage: (String) -> Void
    private let openURL: (URL) -> Void
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
        text: UIKitAnytypeText,
        upperBlock: BlockModelProtocol?,
        content: BlockText,
        isCheckable: Bool,
        contextualMenuHandler: DefaultContextualMenuHandler,
        blockDelegate: BlockDelegate,
        actionHandler: EditorActionHandlerProtocol,
        showPage: @escaping (String) -> Void,
        openURL: @escaping (URL) -> Void,
        showStyleMenu:  @escaping (BlockInformation) -> Void)
    {
        self.block = block
        self.text = text
        self.upperBlock = upperBlock
        self.content = content
        self.isCheckable = isCheckable
        self.contextualMenuHandler = contextualMenuHandler
        self.blockDelegate = blockDelegate
        self.actionHandler = actionHandler
        self.showPage = showPage
        self.openURL = openURL
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
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        TextBlockContentConfiguration(
            blockDelegate: blockDelegate,
            text: text,
            block: block,
            upperBlock: upperBlock,
            isCheckable: isCheckable,
            actionHandler: actionHandler,
            showPage: showPage,
            openURL: openURL,
            showStyleMenu: showStyleMenu,
            focusPublisher: focusSubject.eraseToAnyPublisher()
        )
    }
}
