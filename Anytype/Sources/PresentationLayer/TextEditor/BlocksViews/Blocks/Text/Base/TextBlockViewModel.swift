import Combine
import UIKit
import BlocksModels


struct TextBlockViewModel: BlockViewModelProtocol {
    var upperBlock: BlockModelProtocol?

    var indentationLevel: Int
    var information: BlockInformation

    private let block: BlockModelProtocol
    private let content: BlockText
    private let isCheckable: Bool
    private let toggled: Bool
    
    private let contextualMenuHandler: DefaultContextualMenuHandler
    private let blockDelegate: BlockDelegate
    
    private let showPage: (String) -> Void
    private let openURL: (URL) -> Void
    
    private let actionHandler: EditorActionHandlerProtocol
    private let focusSubject = PassthroughSubject<BlockFocusPosition, Never>()
    private let detailsStorage: ObjectDetailsStorageProtocol
    
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
        upperBlock: BlockModelProtocol?,
        content: BlockText,
        isCheckable: Bool,
        contextualMenuHandler: DefaultContextualMenuHandler,
        blockDelegate: BlockDelegate,
        actionHandler: EditorActionHandlerProtocol,
        detailsStorage: ObjectDetailsStorageProtocol,
        showPage: @escaping (String) -> Void,
        openURL: @escaping (URL) -> Void
    ) {
        self.block = block
        self.upperBlock = upperBlock
        self.content = content
        self.isCheckable = isCheckable
        self.contextualMenuHandler = contextualMenuHandler
        self.blockDelegate = blockDelegate
        self.actionHandler = actionHandler
        self.showPage = showPage
        self.openURL = openURL
        self.toggled = block.isToggled
        self.information = block.information
        self.indentationLevel = block.indentationLevel
        self.detailsStorage = detailsStorage
    }
    
    func set(focus: BlockFocusPosition) {
        focusSubject.send(focus)
    }
    
    func didSelectRowInTableView() {}
    
    func makeContextualMenu() -> [ContextualMenu] {
        let restrictions = BlockRestrictionsBuilder.build(content: content)
        
        var actions: [ContextualMenu] = [ .addBlockBelow, .style ]
        
        if restrictions.canApplyStyle(.smartblock(.page)) {
            actions.append(.turnIntoPage)
        }
        
        if restrictions.canDeleteOrDuplicate {
            actions.append(contentsOf: [ .duplicate, .delete ])
        }

        return actions
    }
    
    func handle(action: ContextualMenu) {
        contextualMenuHandler.handle(action: action, info: information)
    }
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        TextBlockContentConfiguration(
            blockDelegate: blockDelegate,
            block: block,
            content: content,
            upperBlock: upperBlock,
            isCheckable: isCheckable,
            actionHandler: actionHandler,
            showPage: showPage,
            openURL: openURL,
            focusPublisher: focusSubject.eraseToAnyPublisher(),
            detailsStorage: detailsStorage
        )
    }
}
