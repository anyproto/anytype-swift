import Combine
import UIKit
import BlocksModels

struct TextBlockURLInputParameters {
    let textView: UITextView
    let rect: CGRect
    let optionHandler: (EditorContextualOption) -> Void
}

struct TextBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation

    private let content: BlockText
    private let isCheckable: Bool
    private let toggled: Bool

    private weak var blockDelegate: BlockDelegate?
    
    private let showPage: (EditorScreenData) -> Void
    private let openURL: (URL) -> Void
    private let showURLBookmarkPopup: (TextBlockURLInputParameters) -> Void
    private let showTextIconPicker: () -> Void

    private let showWaitingView: (String) -> Void
    private let hideWaitingView: () -> Void

    private let actionHandler: BlockActionHandlerProtocol
    private let pasteboardService: PasteboardServiceProtocol
    private let focusSubject: PassthroughSubject<BlockFocusPosition, Never>
    private let resetSubject = PassthroughSubject<BlockText, Never>()
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
        pasteboardService: PasteboardServiceProtocol,
        showPage: @escaping (EditorScreenData) -> Void,
        openURL: @escaping (URL) -> Void,
        showURLBookmarkPopup: @escaping (TextBlockURLInputParameters) -> Void,
        showTextIconPicker: @escaping () -> Void,
        showWaitingView: @escaping (String) -> Void,
        hideWaitingView: @escaping () -> Void,
        markdownListener: MarkdownListener,
        focusSubject: PassthroughSubject<BlockFocusPosition, Never>
    ) {
        self.content = content
        self.isCheckable = isCheckable
        self.blockDelegate = blockDelegate
        self.actionHandler = actionHandler
        self.pasteboardService = pasteboardService
        self.showPage = showPage
        self.openURL = openURL
        self.showURLBookmarkPopup = showURLBookmarkPopup
        self.showTextIconPicker = showTextIconPicker
        self.showWaitingView = showWaitingView
        self.hideWaitingView = hideWaitingView
        self.toggled = info.isToggled
        self.info = info
        self.markdownListener = markdownListener
        self.focusSubject = focusSubject
    }

    func set(focus: BlockFocusPosition) {
        focusSubject.send(focus)
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}

    func textBlockContentConfiguration() -> TextBlockContentConfiguration {
        TextBlockContentConfiguration(
            blockId: info.id,
            content: content,
            alignment: info.alignment.asNSTextAlignment,
            isCheckable: isCheckable,
            isToggled: info.isToggled,
            isChecked: content.checked,
            shouldDisplayPlaceholder: info.isToggled && info.childrenIds.isEmpty,
            focusPublisher: focusSubject.eraseToAnyPublisher(),
            resetPublisher: resetSubject.eraseToAnyPublisher(),
            actions: action()
        )
    }
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        let contentConfiguration = textBlockContentConfiguration()

        let isDragConfigurationAvailable =
            content.contentType != .description && content.contentType != .title

        return contentConfiguration.cellBlockConfiguration(
            indentationSettings: .init(with: info.configurationData),
            dragConfiguration:
                isDragConfigurationAvailable ? .init(id: info.id) : nil
        )
    }

    func action() -> TextBlockContentConfiguration.Actions {
        return .init(
            shouldPaste: { range, textView in
                if pasteboardService.hasValidURL {
                    return true
                }

                pasteboardService.pasteInsideBlock(focusedBlockId: blockId, range: range) {
                    showWaitingView("Paste processing...".localized)
                } completion: { pasteResult in
                    defer {
                        hideWaitingView()
                    }

                    guard let pasteResult = pasteResult else { return }

                    if pasteResult.isSameBlockCaret || pasteResult.blockIds.isEmpty {
                        let range = NSRange(location: pasteResult.caretPosition, length: 0)
                        textView.setFocus(.at(range))
                    }
                }
                return false
            },
            copy: { range in
                pasteboardService.copy(blocksIds: [info.id], selectedTextRange: range)
            },
            createEmptyBlock: { actionHandler.createEmptyBlock(parentId: info.id) },
            showPage: showPage,
            openURL: openURL,
            changeTextStyle: { attribute, range in
                actionHandler.changeTextStyle(attribute, range: range, blockId: info.id)
            },
            handleKeyboardAction: { action, textView in
                actionHandler.handleKeyboardAction(action, currentText: textView.attributedText, info: info)
            },
            becomeFirstResponder: { },
            resignFirstResponder: { },
            textBlockSetNeedsLayout: { _ in blockDelegate?.textBlockSetNeedsLayout() },
            textViewDidChangeText: { textView in
                actionHandler.changeText(textView.attributedText, info: info)
                blockDelegate?.textDidChange(data: blockDelegateData(textView: textView))
            },
            textViewWillBeginEditing: { textView in
                blockDelegate?.willBeginEditing(data: blockDelegateData(textView: textView))
            },
            textViewDidBeginEditing: { textView in
                blockDelegate?.didBeginEditing(view: textView)
            },
            textViewDidEndEditing: { textView in
                resetSubject.send(content)
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
            },
            tapOnCalloutIcon: showTextIconPicker
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
            case .setText:
                break
            }

            return false
        }

        return true
    }

    private func attributedStringWithURL(
        attributedText: NSAttributedString,
        replacementURL: URL,
        replacementText: String,
        range: NSRange
    ) -> NSAttributedString {
        let newRange = NSRange(location: range.location, length: replacementText.count)
        let mutableAttributedString = attributedText.mutable
        mutableAttributedString.replaceCharacters(in: range, with: replacementText)

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
        let trimmedText = replacementText.trimmed
        var urlString = trimmedText

        if !urlString.isEncoded {
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString
        }

        guard urlString.isValidURL(), let url = URL(string: urlString) else {
            return false
        }

        let newText = attributedStringWithURL(
            attributedText: textView.attributedText,
            replacementURL: url,
            replacementText: replacementText.trimmed,
            range: range
        )

        actionHandler.changeTextForced(newText, blockId: blockId)
        textView.attributedText = newText
        textView.typingAttributes = previousTypingAttributes

        let replacementRange = NSRange(location: range.location, length: trimmedText.count)

        guard let textRect = textView.textRectForRange(range: replacementRange) else { return true }

        let urlIputParameters = TextBlockURLInputParameters(
            textView: textView,
            rect: textRect) { option in
                switch option {
                case .createBookmark:
                    let position: BlockPosition = textView.text == trimmedText ?
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
}
