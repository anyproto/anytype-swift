import BlocksModels
import Combine
import UIKit

struct SimpleTablesTextBlockActionHandler: TextBlockActionHandlerProtocol {
    let info: BlockInformation

    let showPage: (EditorScreenData) -> Void
    let openURL: (URL) -> Void
    let showTextIconPicker: () -> Void
    let resetSubject = PassthroughSubject<Void, Never>()

    private let showWaitingView: (String) -> Void
    private let hideWaitingView: () -> Void
    private let onKeyboardAction: (CustomTextView.KeyboardAction) -> Void
    private let content: BlockText
    private let actionHandler: BlockActionHandlerProtocol
    private let pasteboardService: PasteboardServiceProtocol
    private let mentionDetecter = MentionTextDetector()
    private let markdownListener: MarkdownListener
    private let responderScrollViewHelper: ResponderScrollViewHelper
    private weak var blockDelegate: BlockDelegate?


    init(
        info: BlockInformation,
        showPage: @escaping (EditorScreenData) -> Void,
        openURL: @escaping (URL) -> Void,
        showTextIconPicker: @escaping () -> Void,
        showWaitingView: @escaping (String) -> Void,
        hideWaitingView: @escaping () -> Void,
        content: BlockText,
        actionHandler: BlockActionHandlerProtocol,
        pasteboardService: PasteboardServiceProtocol,
        markdownListener: MarkdownListener,
        blockDelegate: BlockDelegate?,
        onKeyboardAction: @escaping (CustomTextView.KeyboardAction) -> Void,
        responderScrollViewHelper: ResponderScrollViewHelper
    ) {
        self.info = info
        self.showPage = showPage
        self.openURL = openURL
        self.showTextIconPicker = showTextIconPicker
        self.showWaitingView = showWaitingView
        self.hideWaitingView = hideWaitingView
        self.content = content
        self.actionHandler = actionHandler
        self.pasteboardService = pasteboardService
        self.markdownListener = markdownListener
        self.blockDelegate = blockDelegate
        self.onKeyboardAction = onKeyboardAction
        self.responderScrollViewHelper = responderScrollViewHelper
    }

    func textBlockActions() -> TextBlockContentConfiguration.Actions {
        .init(shouldPaste: shouldPaste(range:textView:),
              copy: copy(range:),
              createEmptyBlock: createEmptyBlock,
              showPage: showPage,
              openURL: openURL,
              changeTextStyle: changeStyle(type:on:),
              handleKeyboardAction: handleKeyboardAction(action:textView:),
              becomeFirstResponder: { },
              resignFirstResponder: { },
              textBlockSetNeedsLayout: textBlockSetNeedsLayout(textView:),
              textViewDidChangeText: textViewDidChangeText(textView:),
              textViewWillBeginEditing: textViewWillBeginEditing(textView:),
              textViewDidBeginEditing: textViewDidBeginEditing(textView:),
              textViewDidEndEditing: textViewDidEndEditing(textView:),
              textViewDidChangeCaretPosition: textViewDidChangeCaretPosition(textView:range:),
              textViewShouldReplaceText: textViewShouldReplaceText(textView:replacementText:range:),
              toggleCheckBox: toggleCheckBox,
              toggleDropDown: toggleCheckBox,
              tapOnCalloutIcon: showTextIconPicker
        )
    }

    private func blockDelegateData(textView: UITextView) -> TextBlockDelegateData {
        .init(textView: textView, info: info, text: content.anytypeText, usecase: .simpleTable)
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
            case let .addBlock(type, newText):
                actionHandler.changeTextForced(newText, blockId: info.id)
                actionHandler.addBlock(type, blockId: info.id, blockText: newText, position: .top)
            case let .addStyle(style, newText, styleRange, focusRange):
                actionHandler.setTextStyle(style, range: styleRange, blockId: info.id, currentText: newText)
                textView.setFocus(.at(focusRange))
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

        actionHandler.changeTextForced(newText, blockId: info.id)
        textView.attributedText = newText
        textView.typingAttributes = previousTypingAttributes

        return true
    }

    private func shouldPaste(range: NSRange, textView: UITextView) -> Bool {
        if pasteboardService.hasValidURL {
            return true
        }

        pasteboardService.pasteInsideBlock(focusedBlockId: info.id, range: range) {
            showWaitingView(Loc.pasteProcessing)
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
    }

    private func copy(range: NSRange) {
        pasteboardService.copy(blocksIds: [info.id], selectedTextRange: range)
    }

    private func createEmptyBlock() {
        actionHandler.createEmptyBlock(parentId: info.id)
    }

    private func changeStyle(type: MarkupType, on range: NSRange) {
        actionHandler.changeTextStyle(type, range: range, blockId: info.id)
    }

    private func handleKeyboardAction(action: CustomTextView.KeyboardAction, textView: UITextView) {
        onKeyboardAction(action)
    }

    private func textBlockSetNeedsLayout(textView: UITextView) { }

    private func textViewDidChangeText(textView: UITextView) {
        actionHandler.changeText(textView.attributedText, info: info)
        blockDelegate?.textDidChange(data: blockDelegateData(textView: textView))

        responderScrollViewHelper.textViewDidBeginEditing(textView: textView)
    }

    private func textViewWillBeginEditing(textView: UITextView) {
        blockDelegate?.willBeginEditing(data: blockDelegateData(textView: textView))
    }

    private func textViewDidBeginEditing(textView: UITextView) {
        blockDelegate?.didBeginEditing(view: textView)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            responderScrollViewHelper.textViewDidBeginEditing(textView: textView)
        }
    }

    private func textViewDidEndEditing(textView: UITextView) {
        blockDelegate?.didEndEditing(data: blockDelegateData(textView: textView))
    }

    private func textViewDidChangeCaretPosition(textView: UITextView, range: NSRange) {
        blockDelegate?.selectionDidChange(
            data: blockDelegateData(textView: textView),
            range: range
        )
    }

    private func toggleCheckBox() {
        actionHandler.checkbox(selected: !content.checked, blockId: info.id)
    }

    private func toggleDropdownView() {
        info.toggle()
        actionHandler.toggle(blockId: info.id)
    }
}
