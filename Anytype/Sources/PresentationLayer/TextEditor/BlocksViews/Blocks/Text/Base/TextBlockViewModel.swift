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
    private let isFirstResponder: Bool

    private weak var blockDelegate: BlockDelegate
    
    private let showPage: (EditorScreenData) -> Void
    private let openURL: (URL) -> Void
    
    private let actionHandler: BlockActionHandlerProtocol
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
        upperBlock: BlockModelProtocol?,
        content: BlockText,
        isCheckable: Bool,
        blockDelegate: BlockDelegate,
        actionHandler: BlockActionHandlerProtocol,
        showPage: @escaping (EditorScreenData) -> Void,
        openURL: @escaping (URL) -> Void
    ) {
        self.block = block
        self.upperBlock = upperBlock
        self.content = content
        self.isCheckable = isCheckable
        self.blockDelegate = blockDelegate
        self.actionHandler = actionHandler
        self.showPage = showPage
        self.openURL = openURL
        self.toggled = block.isToggled
        self.information = block.information
        self.indentationLevel = block.indentationLevel
    }
    
    func set(focus: BlockFocusPosition) {
        focusSubject.send(focus)
    }
    
    func didSelectRowInTableView() {}
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {

        let createEmptyBlock: () -> Void = {
            self?.actionHandler.createEmptyBlock(parentId: information.id)
        }
        TextBlockContentConfiguration(
            blockDelegate: blockDelegate,
            block: block,
            content: content,
            upperBlock: upperBlock,
            isCheckable: isCheckable,
            actionHandler: actionHandler,
            showPage: showPage,
            openURL: openURL,
            focusPublisher: focusSubject.eraseToAnyPublisher()
        )
    }
}
