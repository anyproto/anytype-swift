import Combine
import UIKit
import BlocksModels

struct TextBlockURLInputParameters {
    let textView: UITextView
    let rect: CGRect
    let optionHandler: (EditorContextualOption) -> Void
}

struct TextBlockViewModel: BlockViewModelProtocol {
    var info: BlockInformation

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
            info,
            isCheckable,
            toggled
        ] as [AnyHashable]
    }
    
    init(
        info: BlockInformation,
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
        self.content = content
        self.isCheckable = isCheckable
        self.blockDelegate = blockDelegate
        self.actionHandler = actionHandler
        self.showPage = showPage
        self.openURL = openURL
        self.showURLBookmarkPopup = showURLBookmarkPopup
        self.toggled = info.isToggled
        self.info = info
        self.markdownListener = markdownListener
        self.focusSubject = focusSubject
    }

    func set(focus: BlockFocusPosition) {
        focusSubject.send(focus)
    }
    
    func didSelectRowInTableView() {}
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        let contentConfiguration = TextBlockContentConfiguration(
            blockId: info.id,
            content: content,
            alignment: info.alignment.asNSTextAlignment,
            backgroundColor: info.backgroundColor.map { UIColor.Background.uiColor(from: $0) },
            isCheckable: isCheckable,
            isToggled: info.isToggled,
            isChecked: content.checked,
            shouldDisplayPlaceholder: info.isToggled && info.childrenIds.isEmpty,
            focusPublisher: focusSubject.eraseToAnyPublisher(),
            actions: action()
        )

        return CellBlockConfiguration(blockConfiguration: contentConfiguration)
    }

    func action() -> TextBlockContentConfiguration.Actions {
        return .init(
            paste: { range in
                let pastboardHelper = PastboardHelper()
                let slots = pastboardHelper.obtainSlots()

                // don't handle paste if only text in clipboard and it's valid url
                if slots.onlyTextSlotAvailable,
                   let textSlot = slots.textSlot,
                   textSlot.isValidURL() {
                    return false
                }
                actionHandler.past(blockId: blockId, range: range)
                return true
            },
            copy: { range in
                actionHandler.copy(blocksIds: [info.id], selectedTextRange: range)
            },
            createEmptyBlock: { actionHandler.createEmptyBlock(parentId: info.id) },
            showPage: showPage,
            openURL: openURL,
            changeTextStyle: { attribute, range in
                actionHandler.changeTextStyle(attribute, range: range, blockId: info.id)
            },
            handleKeyboardAction: { action in
                actionHandler.handleKeyboardAction(action, info: info)
            },
            becomeFirstResponder: {

            },
            resignFirstResponder: {
                
            },
            textBlockSetNeedsLayout: {
                blockDelegate?.textBlockSetNeedsLayout()
            },
            textViewDidChangeText: { textView in
                actionHandler.changeText(textView.attributedText, info: info)
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
                actionHandler.checkbox(selected: !content.checked, blockId: info.id)
            },
            toggleDropDown: {
                info.toggle()
                actionHandler.toggle(blockId: info.id)
            }
        )
    }

    private func blockDelegateData(textView: UITextView) -> TextBlockDelegateData {
        .init(textView: textView, info: info, text: content.anytypeText)
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
            actionHandler.changeText(textView.attributedText, info: info)
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
                guard BlockRestrictionsBuilder.build(content:  info.content).canApplyTextStyle(style) else { return true }

                actionHandler.turnInto(style, blockId: info.id)
                actionHandler.changeTextForced(newText, blockId: info.id)
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
