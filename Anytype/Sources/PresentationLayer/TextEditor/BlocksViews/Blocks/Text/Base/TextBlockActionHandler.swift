import Combine
import UIKit
import Services
import AnytypeCore

struct TextBlockURLInputParameters {
    let textView: UITextView
    let rect: CGRect
    let optionHandler: (EditorContextualOption) -> Void
}

struct TextBlockActionHandler: TextBlockActionHandlerProtocol {
    let info: BlockInformation

    let showPage: (BlockId) -> Void
    let openURL: (URL) -> Void
    let showTextIconPicker: () -> Void
    let resetSubject = PassthroughSubject<Void, Never>()

    private let showWaitingView: (String) -> Void
    private let hideWaitingView: () -> Void

    private let content: BlockText
    private let anytypeText: UIKitAnytypeText
    private let showURLBookmarkPopup: (TextBlockURLInputParameters) -> Void
    private let actionHandler: BlockActionHandlerProtocol
    // Fix retain cycle for long paste action
    private weak var pasteboardService: PasteboardServiceProtocol?
    private let mentionDetecter = MentionTextDetector()
    private let markdownListener: MarkdownListener
    private weak var blockDelegate: BlockDelegate?

    init(
        info: BlockInformation,
        showPage: @escaping (BlockId) -> Void,
        openURL: @escaping (URL) -> Void,
        showTextIconPicker: @escaping () -> Void,
        showWaitingView: @escaping (String) -> Void,
        hideWaitingView: @escaping () -> Void,
        content: BlockText,
        anytypeText: UIKitAnytypeText,
        showURLBookmarkPopup: @escaping (TextBlockURLInputParameters) -> Void,
        actionHandler: BlockActionHandlerProtocol,
        pasteboardService: PasteboardServiceProtocol,
        markdownListener: MarkdownListener,
        blockDelegate: BlockDelegate?
    ) {
        self.info = info
        self.showPage = showPage
        self.openURL = openURL
        self.showTextIconPicker = showTextIconPicker
        self.showWaitingView = showWaitingView
        self.hideWaitingView = hideWaitingView
        self.content = content
        self.anytypeText = anytypeText
        self.showURLBookmarkPopup = showURLBookmarkPopup
        self.actionHandler = actionHandler
        self.pasteboardService = pasteboardService
        self.markdownListener = markdownListener
        self.blockDelegate = blockDelegate
    }

    func textBlockActions() -> TextBlockContentConfiguration.Actions {
        .init(shouldPaste: shouldPaste(range:textView:),
              copy: copy(range:),
              cut: cut(range:),
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
              toggleDropDown: toggleDropdownView,
              tapOnCalloutIcon: showTextIconPicker
        )
    }

    private func blockDelegateData(textView: UITextView) -> TextBlockDelegateData {
        .init(textView: textView, info: info, text: anytypeText, usecase: .editor)
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
                resetSubject.send()
            case let .addStyle(style, newText, styleRange, focusRange):
                actionHandler.setTextStyle(style, range: styleRange, blockId: info.id, currentText: newText)
                textView.setFocus(.at(focusRange))
            }

            return false
        }

        return true
    }

    private func makeAttributedString(
        attributedText: NSAttributedString,
        replacementURL: URL?,
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
        
        if let replacementURL = replacementURL {
            modifier.apply(.link(replacementURL), shouldApplyMarkup: true, range: newRange)
        }

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

        let urlString = trimmedText

        guard urlString.isValidURL(), let url = AnytypeURL(string: urlString) else {
            return false
        }

        let newTextWithLink = makeAttributedString(
            attributedText: textView.attributedText,
            replacementURL: url.url,
            replacementText: replacementText.trimmed,
            range: range
        )

        actionHandler.changeTextForced(newTextWithLink, blockId: info.id)
        textView.attributedText = newTextWithLink
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
                    
                    let safeSendableAttributedString = SafeSendable(value: originalAttributedString)
                    Task {
                        try await actionHandler.createAndFetchBookmark(
                            targetID: self.info.id,
                            position: position,
                            url: url
                        )
                        
                        safeSendableAttributedString.value.map {
                            actionHandler.changeTextForced($0, blockId: self.info.id)
                        }
                    }
                case .pasteAsLink:
                    break
                case .pasteAsText:
                    let newText = makeAttributedString(
                        attributedText: originalAttributedString ?? NSAttributedString(),
                        replacementURL: nil,
                        replacementText: replacementText.trimmed,
                        range: range
                    )
                    actionHandler.changeTextForced(newText, blockId: info.id)
                }
            }
        showURLBookmarkPopup(urlIputParameters)

        return true
    }

    private func shouldPaste(range: NSRange, textView: UITextView) -> Bool {
        guard let pasteboardService else { return false }
        
        if pasteboardService.hasValidURL {
            return true
        }

        pasteboardService.pasteInsideBlock(focusedBlockId: info.id, range: range) {
            showWaitingView(Loc.pasteProcessing)
        } completion: { [weak textView] pasteResult in
            guard let textView else { return }
            
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
        AnytypeAnalytics.instance().logCopyBlock()
        Task {
            try await pasteboardService?.copy(blocksIds: [info.id], selectedTextRange: range)
        }
    }
    
    private func cut(range: NSRange) {
        Task {
            try await pasteboardService?.cut(blocksIds: [info.id], selectedTextRange: range)
        }
    }

    private func createEmptyBlock() {
        actionHandler.createEmptyBlock(parentId: info.id)
    }

    private func changeStyle(type: MarkupType, on range: NSRange) {
        actionHandler.changeTextStyle(type, range: range, blockId: info.id)
    }

    private func handleKeyboardAction(action: CustomTextView.KeyboardAction, textView: UITextView) {
        actionHandler.handleKeyboardAction(
            action,
            currentText: textView.attributedText,
            info: info
        )
    }

    private func textBlockSetNeedsLayout(textView: UITextView) {
        blockDelegate?.textBlockSetNeedsLayout()
    }

    private func textViewDidChangeText(textView: UITextView) {
        actionHandler.changeText(textView.attributedText, info: info)
        blockDelegate?.textDidChange(data: blockDelegateData(textView: textView))
    }

    private func textViewWillBeginEditing(textView: UITextView) {
        blockDelegate?.willBeginEditing(data: blockDelegateData(textView: textView))
    }

    private func textViewDidBeginEditing(textView: UITextView) {
        blockDelegate?.didBeginEditing(view: textView)
    }

    private func textViewDidEndEditing(textView: UITextView) {
        resetSubject.send()
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
