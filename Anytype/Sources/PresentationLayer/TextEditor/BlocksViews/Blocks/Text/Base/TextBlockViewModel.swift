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

    private var blockDelegate: BlockDelegate
    
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
        let contentConfiguration = TextBlockContentConfiguration(
            content: content,
            alignment: information.alignment.asNSTextAlignment,
            backgroundColor: information.backgroundColor.map { UIColor.Background.uiColor(from: $0) },
            isCheckable: isCheckable,
            isToggled: block.isToggled,
            isChecked: content.checked,
            shouldDisplayPlaceholder: block.isToggled && block.information.childrenIds.isEmpty,
            focusPublisher: focusSubject.eraseToAnyPublisher(),
            actions: action()
        )

        return CellBlockConfiguration(blockConfiguration: contentConfiguration)
    }

    func action() -> TextBlockContentConfiguration.Actions {
        return .init(
            createEmptyBlock: { actionHandler.createEmptyBlock(parentId: information.id) },
            showPage: showPage,
            openURL: openURL,
            changeText: { attributedText in
                actionHandler.changeText(attributedText, info: information)
                blockDelegate.textDidChange()
            },
            changeTextStyle: { attribute, range in
                actionHandler.changeTextStyle(attribute, range: range, blockId: information.id)
            },
            handleKeyboardAction: { (keyboardAction, attributedString) in
                actionHandler.handleKeyboardAction(keyboardAction, info: information, attributedText: attributedString)
            },
            becomeFirstResponder: {
                blockDelegate.becomeFirstResponder(blockId: information.id)
            },
            resignFirstResponder: {
                blockDelegate.resignFirstResponder(blockId: information.id)
            },
            textBlockSetNeedsLayout: {
                blockDelegate.textBlockSetNeedsLayout()
            },
            textViewWillBeginEditing: { textView in
                blockDelegate.willBeginEditing(data: .init(textView: textView, block: block, text: content.anytypeText))
            },
            textViewDidBeginEditing: { _ in
                blockDelegate.didBeginEditing()
            },
            textViewDidEndEditing: { _ in
                blockDelegate.didEndEditing()
            },
            textViewDidChangeCaretPosition: { caretPositionRange in
                actionHandler.changeCaretPosition(range: caretPositionRange)
                blockDelegate.selectionDidChange(range: caretPositionRange)
            },
            textViewDidApplyChangeType: { textChangeType in
                blockDelegate.textWillChange(changeType: textChangeType)
            },
            toggleCheckBox: {
                actionHandler.checkbox(selected: !content.checked, blockId: information.id)
            },
            toggleDropDown: {
                block.toggle()
                actionHandler.toggle(blockId: information.id)
            }
        )
    }
}
