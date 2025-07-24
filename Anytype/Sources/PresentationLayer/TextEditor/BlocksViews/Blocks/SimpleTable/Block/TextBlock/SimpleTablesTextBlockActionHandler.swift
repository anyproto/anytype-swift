import Services
import Combine
import UIKit
import AnytypeCore


final class SimpleTablesTextBlockActionHandler: TextBlockActionHandlerProtocol {
    private let document: any BaseDocumentProtocol
    var info: BlockInformation
    
    let showObject: (String) -> Void
    let openURL: (URL) -> Void
    private let onShowStyleMenu: (BlockInformation) -> Void
    private let onEnterSelectionMode: (BlockInformation) -> Void
    private let onSelectUndoRedo: () -> Void
    let showTextIconPicker: () -> Void
    let resetSubject = PassthroughSubject<NSAttributedString?, Never>()
    let focusSubject: PassthroughSubject<BlockFocusPosition, Never>
    
    private let showWaitingView: (String) -> Void
    private let hideWaitingView: () -> Void
    private let actionHandler: any BlockActionHandlerProtocol
    private let markupChanger: any BlockMarkupChangerProtocol
    
    // Fix retain cycle for long paste action
    private weak var pasteboardService: (any PasteboardBlockDocumentServiceProtocol)?
    private let mentionDetecter = MentionTextDetector()
    private let markdownListener: any MarkdownListener

    private let onKeyboardAction: (CustomTextView.KeyboardAction) -> Void
//    private let collectionController: EditorCollectionReloadable
    
    private let cursorManager: EditorCursorManager
    private let accessoryViewStateManager: any AccessoryViewStateManager
    private let responderScrollViewHelper: ResponderScrollViewHelper
    
    weak var viewModel: TextBlockViewModel?
    
    // MARK: - Dynamic
    private var changeType: TextChangeType?
    
    var accessoryState: AccessoryViewInputState = .none
    
    init(
        document: some BaseDocumentProtocol,
        info: BlockInformation,
        focusSubject: PassthroughSubject<BlockFocusPosition, Never>,
        actionHandler: some BlockActionHandlerProtocol,
        pasteboardService: some PasteboardBlockDocumentServiceProtocol,
        markdownListener: some MarkdownListener,
        //        collectionController: EditorCollectionReloadable,
        cursorManager: EditorCursorManager,
        accessoryViewStateManager: some AccessoryViewStateManager,
        markupChanger: some BlockMarkupChangerProtocol,
        responderScrollViewHelper: ResponderScrollViewHelper,
        showObject: @escaping (String) -> Void,
        openURL: @escaping (URL) -> Void,
        onShowStyleMenu: @escaping (BlockInformation) -> Void,
        onEnterSelectionMode: @escaping (BlockInformation) -> Void,
        onSelectUndoRedo: @escaping () -> Void,
        showTextIconPicker: @escaping () -> Void,
        showWaitingView: @escaping (String) -> Void,
        hideWaitingView: @escaping () -> Void,
        onKeyboardAction: @escaping (CustomTextView.KeyboardAction) -> Void
    ) {
        self.document = document
        self.info = info
        self.focusSubject = focusSubject
        self.showObject = showObject
        self.openURL = openURL
        self.onShowStyleMenu = onShowStyleMenu
        self.onEnterSelectionMode = onEnterSelectionMode
        self.onSelectUndoRedo = onSelectUndoRedo
        self.showTextIconPicker = showTextIconPicker
        self.showWaitingView = showWaitingView
        self.hideWaitingView = hideWaitingView
        self.actionHandler = actionHandler
        self.pasteboardService = pasteboardService
        self.markdownListener = markdownListener
        self.cursorManager = cursorManager
        self.accessoryViewStateManager = accessoryViewStateManager
        self.markupChanger = markupChanger
        self.onKeyboardAction = onKeyboardAction
        self.responderScrollViewHelper = responderScrollViewHelper
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
            usecase: .simpleTable,
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
        
        let modifier = MarkStyleModifier(
            attributedString: mutableAttributedString,
            anytypeFont: content.contentType.uiFont
        )
        
        if let replacementURL = replacementURL {
            modifier.apply(.link(replacementURL), shouldApplyMarkup: true, range: newRange)
        }
        
        return NSAttributedString(attributedString: modifier.attributedString)
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
        onKeyboardAction(action)
    }
    
    private func textBlockSetNeedsLayout(textView: UITextView) {}
    
    @MainActor
    private func textViewDidChangeText(textView: UITextView) {
        changeType.map { accessoryViewStateManager.textDidChange(changeType: $0) }
        
        switch accessoryState {
        case .none:
            Task {
                try await actionHandler.changeText(textView.attributedText.sendable(), blockId: info.id)
            }
        case .search:
            break
        }
    }
    
    private func textViewWillBeginEditing(textView: UITextView) {}
    
    @MainActor
    private func textViewDidBeginEditing(textView: UITextView) {
        accessoryViewStateManager.didBeginEdition(with: accessoryConfiguration(using: textView))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.responderScrollViewHelper.scrollBlockToVisibleArea(textView: textView)
        }
    }
    
    @MainActor
    private func textViewDidEndEditing(textView: UITextView) {
        accessoryViewStateManager.didEndEditing(with: accessoryConfiguration(using: textView))
    }
    
    @MainActor
    private func textViewDidChangeCaretPosition(textView: UITextView, range: NSRange) {
        accessoryViewStateManager.selectionDidChange(range: range)
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

extension SimpleTablesTextBlockActionHandler: AccessoryViewOutput {
    @MainActor
    func showLinkToSearch(range: NSRange, text: NSAttributedString) {
        return
    }
    
    func setNewText(attributedString: SafeNSAttributedString) async throws {
        resetSubject.send(attributedString.value)
        try await actionHandler.changeText(attributedString, blockId: info.id)
    }
    
    func changeText(attributedString: SafeNSAttributedString) async throws {
        try await actionHandler.changeText(attributedString, blockId: info.id)
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
    ) {
        anytypeAssertionFailure("Simple tables should not have slash selection")
    }
    
    func didSelectEditButton() {
        onEnterSelectionMode(info)
    }
    
    func didSelectShowStyleMenu() {
        onShowStyleMenu(info)
    }
    
    func didSelectUndoRedo() {
        onSelectUndoRedo()
    }
}
