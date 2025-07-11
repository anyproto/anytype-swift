import Combine
import UIKit
import Services
import AnytypeCore

struct TextBlockURLInputParameters {
    let textView: UITextView
    let rect: CGRect
    let optionHandler: (EditorContextualOption) -> Void
}

@MainActor
final class TextBlockActionHandler: TextBlockActionHandlerProtocol {
    private let document: any BaseDocumentProtocol
    var info: BlockInformation

    let showObject: (String) -> Void
    let openURL: (URL) -> Void
    private let onShowStyleMenu: (BlockInformation) -> Void
    private let onEnterSelectionMode: (BlockInformation) -> Void
    let showTextIconPicker: () -> Void
    let resetSubject = PassthroughSubject<NSAttributedString?, Never>()
    let focusSubject: PassthroughSubject<BlockFocusPosition, Never>

    private let showWaitingView: (String) -> Void
    private let hideWaitingView: () -> Void
    private let openLinkToObject: @MainActor (LinkToObjectSearchModuleData) -> Void
    private let showURLBookmarkPopup: (TextBlockURLInputParameters) -> Void
    private let actionHandler: any BlockActionHandlerProtocol
    private let markupChanger: any BlockMarkupChangerProtocol
    
    // Fix retain cycle for long paste action
    private weak var pasteboardService: (any PasteboardBlockDocumentServiceProtocol)?
    private let mentionDetecter = MentionTextDetector()
    private let markdownListener: any MarkdownListener
    private let keyboardHandler: any KeyboardActionHandlerProtocol
    private let slashMenuActionHandler: SlashMenuActionHandler
    private let collectionController: any EditorCollectionReloadable
    
    private let cursorManager: EditorCursorManager
    private let accessoryViewStateManager: any AccessoryViewStateManager
    
    weak var viewModel: TextBlockViewModel?
    
    // MARK: - Dynamic
    private var changeType: TextChangeType?
    
    var accessoryState: AccessoryViewInputState = .none

    init(
        document: some BaseDocumentProtocol,
        info: BlockInformation,
        focusSubject: PassthroughSubject<BlockFocusPosition, Never>,
        showObject: @escaping (String) -> Void,
        openURL: @escaping (URL) -> Void,
        onShowStyleMenu: @escaping (BlockInformation) -> Void,
        onEnterSelectionMode: @escaping (BlockInformation) -> Void,
        showTextIconPicker: @escaping () -> Void,
        showWaitingView: @escaping (String) -> Void,
        hideWaitingView: @escaping () -> Void,
        showURLBookmarkPopup: @escaping (TextBlockURLInputParameters) -> Void,
        actionHandler: some BlockActionHandlerProtocol,
        pasteboardService: some PasteboardBlockDocumentServiceProtocol,
        markdownListener: some MarkdownListener,
        collectionController: some EditorCollectionReloadable,
        cursorManager: EditorCursorManager,
        accessoryViewStateManager: some AccessoryViewStateManager,
        keyboardHandler: some KeyboardActionHandlerProtocol,
        markupChanger: some BlockMarkupChangerProtocol,
        slashMenuActionHandler: SlashMenuActionHandler,
        openLinkToObject: @MainActor @escaping (LinkToObjectSearchModuleData) -> Void
    ) {
        self.document = document
        self.info = info
        self.focusSubject = focusSubject
        self.showObject = showObject
        self.openURL = openURL
        self.onShowStyleMenu = onShowStyleMenu
        self.onEnterSelectionMode = onEnterSelectionMode
        self.showTextIconPicker = showTextIconPicker
        self.showWaitingView = showWaitingView
        self.hideWaitingView = hideWaitingView
        self.showURLBookmarkPopup = showURLBookmarkPopup
        self.actionHandler = actionHandler
        self.pasteboardService = pasteboardService
        self.markdownListener = markdownListener
        self.collectionController = collectionController
        self.cursorManager = cursorManager
        self.accessoryViewStateManager = accessoryViewStateManager
        self.keyboardHandler = keyboardHandler
        self.markupChanger = markupChanger
        self.slashMenuActionHandler = slashMenuActionHandler
        self.openLinkToObject = openLinkToObject
    }

    func textBlockActions() -> TextBlockContentConfiguration.Actions {
        TextBlockContentConfiguration.Actions(
            shouldPaste: { [weak self] range, textView in
                return self?.shouldPaste(range: range, textView: textView) ?? false
            },
            copy: { [weak self] range in
                self?.copy(range: range)
            },
            cut: { [weak self] range in
                self?.cut(range: range)
            },
            createEmptyBlock: { [weak self] in
                self?.createEmptyBlock()
            },
            showObject: { [weak self] in
                self?.showObject($0)
            },
            openURL: { [weak self] in
                self?.openURL($0)
            },
            handleKeyboardAction: { [weak self] action, textView in
                self?.handleKeyboardAction(action: action, textView: textView)
            },
            becomeFirstResponder: { },
            resignFirstResponder: { },
            textBlockSetNeedsLayout: { [weak self] textView in
                self?.textBlockSetNeedsLayout(textView: textView)
            },
            textViewDidChangeText: { [weak self] textView in
                self?.textViewDidChangeText(textView: textView)
            },
            textViewWillBeginEditing: { [weak self] textView in
                self?.textViewWillBeginEditing(textView: textView)
            },
            textViewDidBeginEditing: { [weak self] textView in
                self?.textViewDidBeginEditing(textView: textView)
            },
            textViewDidEndEditing: { [weak self] textView in
                self?.textViewDidEndEditing(textView: textView)
            },
            textViewDidChangeCaretPosition: { [weak self] textView, range in
                self?.textViewDidChangeCaretPosition(textView: textView, range: range)
            },
            textViewShouldReplaceText: { [weak self] textView, replacementText, range in
                return self?.textViewShouldReplaceText(textView: textView, replacementText: replacementText, range: range) ?? false
            },
            toggleCheckBox: { [weak self] in
                self?.toggleCheckBox()
            },
            toggleDropDown: { [weak self] in
                self?.toggleDropdownView()
            },
            tapOnCalloutIcon: { [weak self] in
                self?.showTextIconPicker()
            }
        )
    }

    private func accessoryConfiguration(using textView: UITextView) -> TextViewAccessoryConfiguration {
        TextViewAccessoryConfiguration(
            textView: textView,
            contentType: info.content.type,
            usecase: .editor,
            output: self
        )
    }


    private func textViewShouldReplaceText(
        textView: UITextView,
        replacementText: String,
        range: NSRange
    ) -> Bool {
        changeType = textView
            .textChangeType(changeTextRange: range, replacementText: replacementText)
        
        if mentionDetecter.removeMentionIfNeeded(textView: textView, replacementText: replacementText) {
            Task { @MainActor in
                try await actionHandler.changeText(textView.attributedText.sendable(), blockId: info.id)
            }
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
                guard let content = info.textContent, content.contentType != style else { return true }
                guard BlockRestrictionsBuilder.build(content:  info.content).canApplyTextStyle(style) else { return true }
                
                Task { @MainActor in
                    try await actionHandler.turnInto(style, blockId: info.id)
                    try await setNewText(attributedString: newText.sendable())
                    textView.setFocus(.beginning)
                }
            case let .addBlock(type, newText):
                Task { @MainActor in
                    try await setNewText(attributedString: newText.sendable())
                    try await actionHandler.addBlock(type, blockId: info.id, blockText: newText.sendable(), position: .top)
                    resetSubject.send(nil)
                }
            case let .addStyle(style, currentText, styleRange, focusRange):
                Task { @MainActor in
                    let newText = try await actionHandler.setTextStyle(
                        style,
                        range: styleRange,
                        blockId: info.id,
                        currentText: currentText.sendable(),
                        contentType: info.content.type
                    )
                    resetSubject.send(newText.value)
                    textView.setFocus(.at(focusRange))
                }
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
        
        guard let content = info.textContent else { return mutableAttributedString }

        let anytypeText = UIKitAnytypeText(
            attributedString: mutableAttributedString,
            style: content.contentType.uiFont,
            lineBreakModel: .byWordWrapping
        )
        
        if let replacementURL = replacementURL {
            anytypeText.apply(.link(replacementURL), range: newRange)
        }

        return NSAttributedString(attributedString: anytypeText.attrString)
    }

    private func shouldCreateBookmark(
        textView: UITextView,
        replacementText: String,
        range: NSRange
    ) -> Bool {
        guard isCreateBookmarkAvailableForBlock() else { return false }
        
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
        
        Task { @MainActor in
            try await setNewText(attributedString: newTextWithLink.sendable())
            
            let replacementRange = NSRange(location: range.location, length: trimmedText.count)
            
            guard let textRect = textView.textRectForRange(range: replacementRange) else { return }
            
            let urlIputParameters = TextBlockURLInputParameters(
                textView: textView,
                rect: textRect) { [info, weak self] option in
                    switch option {
                    case .createBookmark:
                        let position: BlockPosition = textView.text == trimmedText ?
                            .replace : .bottom
                        
                        let safeSendableAttributedString = SafeSendable(value: originalAttributedString)
                        Task { @MainActor [weak self] in
                            try await self?.actionHandler.createAndFetchBookmark(
                                targetID: info.id,
                                position: position,
                                url: url
                            )
                            if let value = safeSendableAttributedString.value {
                                try await self?.setNewText(attributedString: value.sendable())
                            }
                        }
                    case .pasteAsLink:
                        break
                    case .pasteAsText:
                        let newText = self?.makeAttributedString(
                            attributedText: originalAttributedString ?? NSAttributedString(),
                            replacementURL: nil,
                            replacementText: replacementText.trimmed,
                            range: range
                        )
                        if let newText {
                            self?.setNewTextSync(attributedString: newText)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if #available(iOS 17.0, *) {
                                SharingTip.didCopyText = true
                            }
                        }
                    }
                }
                showURLBookmarkPopup(urlIputParameters)
        }
        
        return true
    }

    private func shouldPaste(range: NSRange, textView: UITextView) -> Bool {
        guard let pasteboardService else { return false }
        
        if pasteboardService.hasValidURL {
            return true
        }

        pasteboardService.pasteInsideBlock(objectId: document.objectId, spaceId: document.spaceId, focusedBlockId: info.id, range: range) { [weak self] in
            self?.showWaitingView(Loc.pasteProcessing)
        } completion: { [weak textView, weak self] pasteResult in
            guard let textView else { return }
            
            defer {
                self?.hideWaitingView()
            }

            guard let pasteResult = pasteResult else { return }

            if pasteResult.isSameBlockCaret || pasteResult.blockIds.isEmpty {
                let range = NSRange(location: pasteResult.caretPosition, length: 0)
                textView.setFocus(.at(range))
            }
            
            if #available(iOS 17.0, *) {
                SharingTip.didCopyText = true
            }
        }
        return false
    }

    private func copy(range: NSRange) {
        AnytypeAnalytics.instance().logCopyBlock(spaceId: document.spaceId, countBlocks: 1)
        Task {
            try await pasteboardService?.copy(document: document, blocksIds: [info.id], selectedTextRange: range)
        }
    }
    
    private func cut(range: NSRange) {
        Task {
            try await pasteboardService?.cut(document: document, blocksIds: [info.id], selectedTextRange: range)
        }
    }

    private func createEmptyBlock() {
        actionHandler.createEmptyBlock(parentId: info.id)
    }

    private func handleKeyboardAction(action: CustomTextView.KeyboardAction, textView: UITextView) {
        Task { @MainActor in
            try await keyboardHandler.handle(
                info: info,
                textView: textView,
                action: action
            )
            
            viewModel.map { collectionController.reconfigure(items: [.block($0)]) }
        }
    }

    private func textBlockSetNeedsLayout(textView: UITextView) {
        viewModel.map {
            collectionController.itemDidChangeFrame(item: .block($0))
        }
    }
    
    private func isCreateBookmarkAvailableForBlock() -> Bool {
        info.content.type != .text(.title) && info.content.type != .text(.description)
    }

    @MainActor
    private func textViewDidChangeText(textView: UITextView) {
        changeType.map { accessoryViewStateManager.textDidChange(changeType: $0) }
        let text = textView.attributedText.sendable()
        Task {
            try await actionHandler.changeText(text, blockId: info.id)
        }
    }

    @MainActor
    private func textViewWillBeginEditing(textView: UITextView) {
        collectionController.textBlockWillBeginEditing()
        accessoryViewStateManager.willBeginEditing(with: accessoryConfiguration(using: textView))
    }

    @MainActor
    private func textViewDidBeginEditing(textView: UITextView) {
        accessoryViewStateManager.didBeginEdition(with: accessoryConfiguration(using: textView))
        collectionController.textBlockDidBeginEditing(firstResponderView: textView)
    }

    @MainActor
    private func textViewDidEndEditing(textView: UITextView) {
        let configuration = accessoryConfiguration(using: textView)
        
        collectionController.blockDidFinishEditing()
        accessoryViewStateManager.didEndEditing(with: configuration)
    }

    @MainActor
    private func textViewDidChangeCaretPosition(textView: UITextView, range: NSRange) {
        accessoryViewStateManager.selectionDidChange(range: range)
        cursorManager.blockFocus = BlockFocus(id: info.id, position: .at(range))
//        cursorManager.didChangeCursorPosition(at: data.info.id, position: .at(range)) // DO WE NEED IT? WHY?
    }

    private func toggleCheckBox() {
        guard let content = info.textContent else { return }
        actionHandler.checkbox(selected: !content.checked, blockId: info.id)
    }

    private func toggleDropdownView() {
        info.toggle()
        actionHandler.toggle(blockId: info.id)
    }
}

extension TextBlockActionHandler: AccessoryViewOutput {
    @MainActor
    func showLinkToSearch(range: NSRange, text: NSAttributedString) {
        let urlLink = text.linkState(range: range)
        let objectIdLink = text.linkToObjectState(range: range)
        let eitherLink: Either<URL, String>? = urlLink.map { .left($0) } ?? objectIdLink.map { .right($0) } ?? nil
    
        let data = LinkToObjectSearchModuleData(
            spaceId: document.spaceId,
            currentLinkUrl: text.linkState(range: range),
            currentLinkString: text.linkToObjectState(range: range),
            route: .link,
            setLinkToObject: { [weak self] linkBlockId in
                guard let self = self else { return }
                AnytypeAnalytics.instance().logChangeTextStyle(markupType: MarkupType.linkToObject(linkBlockId), objectType: .custom)
                let newText = markupChanger.setMarkup(.linkToObject(linkBlockId), range: range, attributedString: text, contentType: info.content.type)
                setNewTextSync(attributedString: newText)
            },
            setLinkToUrl: { [weak self] url in
                guard let self = self else { return }
                let newText = markupChanger.setMarkup(
                    .link(url),
                    range: range,
                    attributedString: text,
                    contentType: info.content.type
                )
                
                setNewTextSync(attributedString: newText)
            },
            removeLink: { [weak self] in
                guard let self = self else { return }
                switch eitherLink {
                case .right:
                    let newText = markupChanger.removeMarkup(.linkToObject(nil), range: range, contentType: info.content.type, attributedString: text)
                    setNewTextSync(attributedString: newText)
                case .left:
                    let newText = markupChanger.removeMarkup(.link(nil), range: range, contentType: info.content.type, attributedString: text)
                    setNewTextSync(attributedString: newText)
                case .none:
                    break
                }
            },
            willShowNextScreen: nil
        )
        openLinkToObject(data)
    }
    
    func setNewText(attributedString: SafeNSAttributedString) async throws {
        resetSubject.send(attributedString.value)
        try await actionHandler.changeText(attributedString, blockId: info.id)
        
        viewModel.map { collectionController.itemDidChangeFrame(item: .block($0)) }
    }
    
    func changeText(attributedString: SafeNSAttributedString) {
        Task { @MainActor in
            try await actionHandler.changeText(attributedString, blockId: info.id)
        }
    }
    
    func didSelectAddMention(
        _ mention: MentionObject,
        at position: Int,
        attributedString: SafeNSAttributedString
    ) async throws {
        guard let textContent = info.textContent else { return }
        
        let mutableString = NSMutableAttributedString(attributedString: attributedString.value)
        
        mutableString.replaceCharacters(in: .init(location: position, length: 0), with: mention.name)
        
        let anytypeText = UIKitAnytypeText(
            attributedString: mutableString,
            style: textContent.contentType.uiFont,
            lineBreakModel: .byWordWrapping
        )
        
        anytypeText.apply(.mention(mention), range: .init(location: position, length: mention.name.count))
        anytypeText.appendSpace()
        
        let newAttributedString = anytypeText.attrString
                
        try await setNewText(attributedString: newAttributedString.sendable())
        focusSubject.send(.at(.init(location: position + mention.name.count + 2, length: 0)))
    }
    
    func didSelectSlashAction(
        _ action: SlashAction,
        at position: Int,
        textView: UITextView?
    ) async throws {
        try await slashMenuActionHandler.handle(
            action,
            textView: textView,
            blockInformation: info,
            modifiedStringHandler: { [weak resetSubject] modifiedAttributedString in
                resetSubject?.send(modifiedAttributedString.value)
            }
        )
    }
    
    func didSelectEditButton() {
        onEnterSelectionMode(info)
    }
    
    func didSelectShowStyleMenu() {
        onShowStyleMenu(info)
    }
    
    private func setNewTextSync(attributedString: NSAttributedString) {
        Task { try await setNewText(attributedString: attributedString.sendable()) }
    }
}
