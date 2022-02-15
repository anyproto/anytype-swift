import Combine
import UIKit
import BlocksModels

struct TextBlockURLInputParameters {
    let textView: UITextView
    let rect: CGRect
    let optionHandler: (EditorContextualOption) -> Void
}

struct TextBlockViewModel: BlockViewModelProtocol {
    var indentationLevel: Int
    var information: BlockInformation

    private let block: BlockModelProtocol
    private let content: BlockText
    private let isCheckable: Bool
    private let toggled: Bool

    private weak var blockDelegate: BlockDelegate?
    
    private let showPage: (EditorScreenData) -> Void
    private let openURL: (URL) -> Void
    private let showURLBookmarkPopup: (TextBlockURLInputParameters) -> Void
    
    private let actionHandler: BlockActionHandlerProtocol
    private let focusSubject: PassthroughSubject<BlockFocusPosition, Never>
    private let mentionDetecter = MentionTextDetector()
    private let markdownListener: MarkdownListener

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
        blockDelegate: BlockDelegate,
        actionHandler: BlockActionHandlerProtocol,
        showPage: @escaping (EditorScreenData) -> Void,
        openURL: @escaping (URL) -> Void,
        showURLBookmarkPopup: @escaping (TextBlockURLInputParameters) -> Void,
        markdownListener: MarkdownListener,
        focusSubject: PassthroughSubject<BlockFocusPosition, Never>
    ) {
        self.block = block
        self.content = content
        self.isCheckable = isCheckable
        self.blockDelegate = blockDelegate
        self.actionHandler = actionHandler
        self.showPage = showPage
        self.openURL = openURL
        self.showURLBookmarkPopup = showURLBookmarkPopup
        self.toggled = block.isToggled
        self.information = block.information
        self.indentationLevel = block.indentationLevel
        self.markdownListener = markdownListener
        self.focusSubject = focusSubject
    }

    func set(focus: BlockFocusPosition) {
        focusSubject.send(focus)
    }
    
    func didSelectRowInTableView() {}
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        let contentConfiguration = TextBlockContentConfiguration(
            blockId: information.id,
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
            changeTextStyle: { attribute, range in
                actionHandler.changeTextStyle(attribute, range: range, blockId: information.id)
            },
            handleKeyboardAction: { (keyboardAction, attributedString) in
                actionHandler.handleKeyboardAction(keyboardAction, info: information, attributedText: attributedString)
            },
            becomeFirstResponder: {

            },
            resignFirstResponder: {
                
            },
            textBlockSetNeedsLayout: {
                blockDelegate?.textBlockSetNeedsLayout()
            },
            textViewDidChangeText: { textView in
                actionHandler.changeText(textView.attributedText, info: information)
                blockDelegate?.textDidChange(data: blockDelegateData(textView: textView))
            },
            textViewWillBeginEditing: { textView in
                blockDelegate?.willBeginEditing(data: blockDelegateData(textView: textView))
            },
            textViewDidBeginEditing: { _ in
                blockDelegate?.didBeginEditing()
            },
            textViewDidEndEditing: { textView in
                blockDelegate?.didEndEditing(data: blockDelegateData(textView: textView))
            },
            textViewDidChangeCaretPosition: { caretPositionRange in
                blockDelegate?.selectionDidChange(range: caretPositionRange)
            },
            textViewShouldReplaceText: textViewShouldReplaceText,
            toggleCheckBox: {
                actionHandler.checkbox(selected: !content.checked, blockId: information.id)
            },
            toggleDropDown: {
                block.toggle()
                actionHandler.toggle(blockId: information.id)
            }
        )
    }

    private func blockDelegateData(textView: UITextView) -> TextBlockDelegateData {
        .init(textView: textView, block: block, text: content.anytypeText)
    }

    private func textViewShouldReplaceText(
        textView: UITextView,
        replacementText: String,
        range: NSRange
    ) -> Bool {
        let changeType = textView
            .textChangeType(changeTextRange: range, replacementText: replacementText)
        blockDelegate?.textWillChange(changeType: changeType)

        if mentionDetecter.removeMentionIfNeeded(textView: textView, replacementText: replacementText) {
            actionHandler.changeText(textView.attributedText, info: information)
            return false
        }

        if shouldCreateBookmark(textView: textView, replacementText: replacementText, range: range) {
            return false
        }

        if let markdownChange = markdownListener.markdownChange(
            textView: textView,
            replacementText: replacementText,
            range: range
        ) {
            switch markdownChange {
            case let .turnInto(style, newText):
                guard content.contentType != style else { return true }
                guard BlockRestrictionsBuilder.build(content:  information.content).canApplyTextStyle(style) else { return true }

                actionHandler.turnInto(style, blockId: information.id)
                actionHandler.changeTextForced(newText, blockId: information.id)
                textView.setFocus(.beginning)
            case .setText(let text, let caretPosition):
                break
            }

            return false
        }

        return true
    }

    private func attributedStringWithURL(
        attributedText: NSAttributedString,
        replacementURL: URL,
        range: NSRange
    ) -> NSAttributedString {
        let newRange = NSRange(location: range.location, length: replacementURL.absoluteString.count)
        let mutableAttributedString = attributedText.mutable
        mutableAttributedString.replaceCharacters(in: range, with: replacementURL.absoluteString)

        let modifier = MarkStyleModifier(
            attributedString: mutableAttributedString,
            anytypeFont: content.contentType.uiFont
        )

        modifier.apply(.link(replacementURL), shouldApplyMarkup: true, range: newRange)

        return NSAttributedString(attributedString: modifier.attributedString)
    }

    private func shouldCreateBookmark(
        textView: UITextView,
        replacementText: String,
        range: NSRange
    ) -> Bool {
        let previousTypingAttributes = textView.typingAttributes
        let originalAttributedString = textView.attributedText

        if replacementText.isValidURL(), let url = URL(string: replacementText) {
            let newText = attributedStringWithURL(
                attributedText: textView.attributedText,
                replacementURL: url,
                range: range
            )

            actionHandler.changeTextForced(newText, blockId: blockId)
            textView.attributedText = newText
            textView.typingAttributes = previousTypingAttributes

            let replacementRange = NSRange(location: range.location, length: replacementText.count)

            guard let textRect = textView.textRectForRange(range: replacementRange) else { return true }

            let urlIputParameters = TextBlockURLInputParameters(
                textView: textView,
                rect: textRect) { option in
                    switch option {
                    case .createBookmark:
                        let position: BlockPosition = textView.text == replacementText ?
                            .replace : .bottom
                        actionHandler.createAndFetchBookmark(
                            targetID: blockId,
                            position: position,
                            url: url.absoluteString
                        )

                        originalAttributedString.map {
                            actionHandler.changeTextForced($0, blockId: blockId)
                        }
                    case .dismiss:
                        break
                    }
                }

            showURLBookmarkPopup(urlIputParameters)

            return true
        }

        return false
    }
}
