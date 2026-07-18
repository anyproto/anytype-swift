import Combine
import UIKit
import Services
import AnytypeCore
import Factory
import DeepLinks

struct TextBlockURLInputParameters {
    let textView: UITextView
    let rect: CGRect
    let options: [EditorContextualOption]
    let optionHandler: (EditorContextualOption) -> Void
}

@MainActor
final class TextBlockActionHandler: TextBlockActionHandlerProtocol, LinkToSearchDelegate {
    private let document: any BaseDocumentProtocol
    var info: BlockInformation

    let showObject: (String) -> Void
    let openURL: (URL) -> Void
    private let onShowStyleMenu: (BlockInformation) -> Void
    private let onEnterSelectionMode: (BlockInformation) -> Void
    private let onSelectUndoRedo: () -> Void
    private let onDeleteBlock: (BlockInformation) -> Void
    private let onIndentLeft: (BlockInformation) -> Void
    private let onIndentRight: (BlockInformation) -> Void
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
    // Set only for the trailing "tap to type" placeholder. While unmaterialized, mutating
    // paths must not target `info.id` — the block does not exist in the middleware yet.
    private let virtualBlockSession: (any VirtualTrailingBlockSessionProtocol)?
    // Refreshes the live on-screen cell for a block id from current model state. After the
    // empty-block identity fork or the virtual-placeholder materialization, the visible cell is
    // a freshly built handler; this handler's own `resetSubject` drives the replaced (dead) cell.
    // A programmatic text write from the paste menu must therefore refresh the live cell
    // explicitly — this also re-syncs its text view before the next keystroke can read stale text.
    private let reconfigureLiveBlock: @MainActor (String) -> Void

    @Injected(\.linkToSearchHelper)
    private var linkToSearchHelper: any LinkToSearchHelperProtocol

    @Injected(\.deepLinkParser)
    private var deepLinkParser: any DeepLinkParserProtocol

    @Injected(\.universalLinkParser)
    private var universalLinkParser: any UniversalLinkParserProtocol

    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    
    weak var viewModel: TextBlockViewModel?
    
    // MARK: - Dynamic
    private var changeType: TextChangeType?

    var accessoryState: AccessoryViewInputState = .none

    // First fill of an existing empty block replaces it with a fresh identity; see
    // forkEmptyBlockIfNeeded. Kept for the handler's lifetime — once forked, later calls
    // only rebind to the already-created block.
    private var emptyBlockFork: Task<BlockInformation, any Error>?
    private var pendingForkOldId: String?

    init(
        document: some BaseDocumentProtocol,
        info: BlockInformation,
        focusSubject: PassthroughSubject<BlockFocusPosition, Never>,
        showObject: @escaping (String) -> Void,
        openURL: @escaping (URL) -> Void,
        onShowStyleMenu: @escaping (BlockInformation) -> Void,
        onEnterSelectionMode: @escaping (BlockInformation) -> Void,
        onSelectUndoRedo: @escaping () -> Void,
        onDeleteBlock: @escaping (BlockInformation) -> Void,
        onIndentLeft: @escaping (BlockInformation) -> Void,
        onIndentRight: @escaping (BlockInformation) -> Void,
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
        openLinkToObject: @MainActor @escaping (LinkToObjectSearchModuleData) -> Void,
        virtualBlockSession: (any VirtualTrailingBlockSessionProtocol)? = nil,
        reconfigureLiveBlock: @MainActor @escaping (String) -> Void = { _ in }
    ) {
        self.document = document
        self.info = info
        self.focusSubject = focusSubject
        self.showObject = showObject
        self.openURL = openURL
        self.onShowStyleMenu = onShowStyleMenu
        self.onEnterSelectionMode = onEnterSelectionMode
        self.onSelectUndoRedo = onSelectUndoRedo
        self.onDeleteBlock = onDeleteBlock
        self.onIndentLeft = onIndentLeft
        self.onIndentRight = onIndentRight
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
        self.virtualBlockSession = virtualBlockSession
        self.reconfigureLiveBlock = reconfigureLiveBlock
    }

    // MARK: - Virtual trailing block

    private var isVirtualUnmaterialized: Bool {
        guard let virtualBlockSession else { return false }
        return !virtualBlockSession.isMaterialized
    }

    /// Creates the real trailing block carrying `attrText` and rebinds this handler to it.
    /// Returns true when this call's content was carried by the BlockCreate request, so no
    /// follow-up text sync is needed.
    @discardableResult
    private func materializeVirtualBlock(
        carrying attrText: NSAttributedString,
        style: BlockText.Style? = nil,
        focusAt: BlockFocusPosition?
    ) async throws -> Bool {
        guard let virtualBlockSession, !virtualBlockSession.isMaterialized else { return false }
        guard var content = info.textContent else { return false }
        let middlewareString = AttributedTextConverter.asMiddleware(attributedText: attrText)
        content.text = middlewareString.text
        content.marks = middlewareString.marks
        if let style {
            content.contentType = style
        }
        let materialization = try await virtualBlockSession.materialize(carrying: content, focusAt: focusAt)
        info = materialization.info
        return materialization.contentCarried
    }

    private func virtualBlockCanSyncTextChange(_ textView: UITextView) -> Bool {
        // Wait for the IME commit — creating the block mid-composition would bounce the
        // first responder and break the composition.
        guard textView.markedTextRange == nil else { return false }
        // During a slash/mention session typing is a local search filter; the commit paths
        // (setNewText, didSelectSlashAction) materialize with the final text.
        if case .search = accessoryState { return false }
        // Empty text creates nothing, but a deletion racing an in-flight creation must
        // still propagate to the created block.
        return textView.attributedText.length > 0 || virtualBlockSession?.isMaterializing == true
    }

    private func endOfTextFocus(_ attrText: NSAttributedString) -> BlockFocusPosition {
        .at(NSRange(location: attrText.length, length: 0))
    }

    // MARK: - Empty block identity fork

    private func canForkEmptyBlockOnFill(_ newText: NSAttributedString) -> Bool {
        guard FeatureFlags.forkEmptyBlockOnFill else { return false }
        // The virtual trailing block creates its real block with content directly.
        guard virtualBlockSession == nil else { return false }
        guard newText.length > 0 else { return false }
        guard let content = info.textContent, content.text.isEmpty else { return false }
        // Replacing a block with children would orphan them.
        guard info.childrenIds.isEmpty else { return false }
        switch content.contentType {
        case .title, .description, .code:
            return false
        default:
            return true
        }
    }

    /// First content into an existing empty block forks its identity via BlockReplace: two
    /// clients filling the same empty block concurrently end up with two blocks — both texts
    /// survive — instead of one whole-value last-writer-wins text. Returns true when this
    /// call's content was carried by the replace request.
    @discardableResult
    private func forkEmptyBlockIfNeeded(carrying attrText: NSAttributedString, focusAt: BlockFocusPosition?) async throws -> Bool {
        if let emptyBlockFork {
            let newInfo = try await emptyBlockFork.value
            // Rebind only while still pointing at the replaced id — repeated calls must not
            // keep resetting `info` to the fork-time snapshot.
            if info.id != newInfo.id {
                info = newInfo
            }
            return false
        }
        guard canForkEmptyBlockOnFill(attrText) else { return false }

        let middlewareString = AttributedTextConverter.asMiddleware(attributedText: attrText)
        let oldInfo = info
        let task = Task { try await actionHandler.replaceEmptyBlock(info: oldInfo, middlewareString: middlewareString, focusAt: focusAt) }
        emptyBlockFork = task
        pendingForkOldId = oldInfo.id
        do {
            info = try await task.value
            return true
        } catch {
            emptyBlockFork = nil
            pendingForkOldId = nil
            anytypeAssertionFailure("Empty block identity fork failed", info: ["error": error.localizedDescription])
            throw error
        }
    }

    /// Ensures a concrete middleware block carries `attrText` before a text mutation: first via the
    /// virtual placeholder's BlockCreate, then via the empty-block identity fork. Each step is a
    /// no-op when it doesn't apply. Returns true when one of them carried the content, so the caller
    /// can skip its own text sync.
    private func carryOrSync(_ attrText: NSAttributedString, focusAt: BlockFocusPosition?) async throws -> Bool {
        if try await materializeVirtualBlock(carrying: attrText, focusAt: focusAt) { return true }
        return try await forkEmptyBlockIfNeeded(carrying: attrText, focusAt: focusAt)
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
                if try await carryOrSync(textView.attributedText, focusAt: nil) { return }
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
            if isVirtualUnmaterialized {
                handleVirtualMarkdownChange(markdownChange)
                return false
            }
            switch markdownChange {
            case let .turnInto(style, newText):
                guard let content = info.textContent, content.contentType != style else { return true }
                guard BlockRestrictionsBuilder.build(content:  info.content).canApplyTextStyle(style) else { return true }

                Task { @MainActor in
                    try await forkEmptyBlockIfNeeded(carrying: newText, focusAt: .beginning)
                    try await actionHandler.turnInto(style, blockId: info.id)
                    try await setNewText(attributedString: newText.sendable())
                    resetSubject.send(nil)
                    textView.setFocus(.beginning)
                }
            case let .addBlock(type, newText):
                Task { @MainActor in
                    try await forkEmptyBlockIfNeeded(carrying: newText, focusAt: .beginning)
                    try await setNewText(attributedString: newText.sendable())
                    try await actionHandler.addBlock(type, blockId: info.id, blockText: newText.sendable(), position: .top)
                    resetSubject.send(nil)
                }
            case let .addStyle(style, currentText, styleRange, focusRange):
                Task { @MainActor in
                    try await forkEmptyBlockIfNeeded(carrying: currentText, focusAt: .at(focusRange))
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

    private func handleVirtualMarkdownChange(_ markdownChange: MarkdownChange) {
        switch markdownChange {
        case let .turnInto(style, newText):
            guard let content = info.textContent, content.contentType != style else { return }
            guard BlockRestrictionsBuilder.build(content: info.content).canApplyTextStyle(style) else { return }
            resetSubject.send(newText)
            Task { @MainActor in
                try await materializeVirtualBlock(carrying: newText, style: style, focusAt: .beginning)
            }
        case let .addBlock(type, newText):
            resetSubject.send(newText)
            Task { @MainActor in
                try await materializeVirtualBlock(carrying: newText, focusAt: .beginning)
                try await actionHandler.addBlock(type, blockId: info.id, blockText: newText.sendable(), position: .top)
            }
        case let .addStyle(style, currentText, styleRange, focusRange):
            let styledText = markupChanger.setMarkup(
                style,
                range: styleRange,
                attributedString: currentText,
                contentType: info.content.type
            )
            resetSubject.send(styledText)
            Task { @MainActor in
                try await materializeVirtualBlock(carrying: styledText, focusAt: .at(focusRange))
            }
        }
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

        // Link blocks can only target objects in the current space.
        // Cross-space links and self-links fall back to the standard menu.
        // Accept both anytype:// deep links and https://object.any.coop/... web links.
        let pastedObjectId: String? = parsedLocalObjectId(from: url.url)

        let options: [EditorContextualOption] = pastedObjectId != nil
            ? [.object, .createBookmark, .pasteAsLink, .pasteAsText]
            : [.createBookmark, .pasteAsLink, .pasteAsText]

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
                rect: textRect,
                options: options) { [info, weak self] option in
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
                            // For .replace the source block is destroyed, so restoring its text
                            // would target a nonexistent block (BlockTextSetText: not found).
                            if position == .bottom, let value = safeSendableAttributedString.value {
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
                            self?.setNewTextRefreshingLiveBlock(attributedString: newText)
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            SharingTip.didCopyText = true
                        }
                    case .object:
                        guard let pastedObjectId else { break }
                        let position: BlockPosition = textView.text == trimmedText ?
                            .replace : .bottom

                        let safeSendableAttributedString = SafeSendable(value: originalAttributedString)
                        Task { @MainActor [weak self] in
                            guard let self else { return }
                            do {
                                let details = try await self.objectDetails(forObjectId: pastedObjectId)
                                try await self.actionHandler.addLink(
                                    targetDetails: details,
                                    blockId: info.id,
                                    position: position,
                                    route: .clipboard
                                )
                                // For .replace the source block is destroyed; nothing to restore.
                                if position == .bottom, let value = safeSendableAttributedString.value {
                                    try await self.setNewText(attributedString: value.sendable())
                                }
                            } catch {
                                anytypeAssertionFailure(error.localizedDescription)
                            }
                        }
                    }
                }
                showURLBookmarkPopup(urlIputParameters)
        }
        
        return true
    }

    private func shouldPaste(range: NSRange, textView: UITextView) -> Bool {
        guard pasteboardService != nil else { return false }

        if pasteboardService?.hasValidURL == true {
            return true
        }

        if isVirtualUnmaterialized {
            Task { @MainActor in
                try await materializeVirtualBlock(carrying: textView.attributedText, focusAt: .beginning)
                performPaste(range: range, textView: textView)
            }
            return false
        }

        performPaste(range: range, textView: textView)
        return false
    }

    private func performPaste(range: NSRange, textView: UITextView) {
        guard let pasteboardService else { return }

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

            SharingTip.didCopyText = true
        }
    }

    private func copy(range: NSRange) {
        guard !isVirtualUnmaterialized else { return }
        AnytypeAnalytics.instance().logCopyBlock(countBlocks: 1)
        Task {
            try await pasteboardService?.copy(document: document, blocksIds: [info.id], selectedTextRange: range)
        }
    }

    private func cut(range: NSRange) {
        guard !isVirtualUnmaterialized else { return }
        Task {
            try await pasteboardService?.cut(document: document, blocksIds: [info.id], selectedTextRange: range)
        }
    }

    private func createEmptyBlock() {
        guard !isVirtualUnmaterialized else { return }
        actionHandler.createEmptyBlock(parentId: info.id)
    }

    private func handleKeyboardAction(action: CustomTextView.KeyboardAction, textView: UITextView) {
        Task { @MainActor in
            if isVirtualUnmaterialized {
                if case .delete = action {
                    virtualBlockSession?.dismissAndFocusPreviousBlock()
                    return
                }
                try await materializeVirtualBlock(carrying: textView.attributedText, focusAt: endOfTextFocus(textView.attributedText))
            }
            // A keyboard action racing ahead of the first keystroke's task can become the fork
            // initiator; carry a real focus so the caret survives either ordering. Actions that
            // set their own focus afterwards (split/merge) simply overwrite it.
            try await forkEmptyBlockIfNeeded(carrying: textView.attributedText, focusAt: endOfTextFocus(textView.attributedText))
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
        let caret = textView.selectedRange
        if isVirtualUnmaterialized {
            Task { [weak textView] in
                // Checked after the current call stack unwinds: the toolbar slash/mention
                // buttons insert their trigger symbol first and open the search session
                // right after this callback, and that session must stay on this text view.
                guard let textView, virtualBlockCanSyncTextChange(textView) else { return }
                let contentCarried = try await materializeVirtualBlock(carrying: text.value, focusAt: .at(caret))
                guard !contentCarried else { return }
                try await actionHandler.changeText(text, blockId: info.id)
            }
            return
        }
        Task { [weak textView] in
            if emptyBlockFork == nil, canForkEmptyBlockOnFill(text.value) {
                // Defer the fork to the IME/search-session commit; nothing syncs meanwhile,
                // so the shared empty register is never written. Checked after the call
                // stack unwinds so toolbar-inserted "/"/"@" sessions are already open.
                if let textView, textView.markedTextRange != nil { return }
                if case .search = accessoryState { return }
            }
            let contentCarried = try await forkEmptyBlockIfNeeded(carrying: text.value, focusAt: .at(caret))
            guard !contentCarried else { return }
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
        if isVirtualUnmaterialized {
            let text = textView.attributedText.sendable()
            if text.value.length > 0 {
                // Keep text typed during a still-open slash/mention session or an abandoned
                // IME composition — losing it on defocus would be worse than creating the block.
                Task { try await materializeVirtualBlock(carrying: text.value, focusAt: nil) }
            } else {
                virtualBlockSession?.dismiss()
            }
        } else if emptyBlockFork == nil, canForkEmptyBlockOnFill(textView.attributedText) {
            // Text held back during a slash/mention session or an IME composition must not
            // be lost on defocus.
            let text = textView.attributedText.sendable()
            Task { try await forkEmptyBlockIfNeeded(carrying: text.value, focusAt: nil) }
        }
        if let virtualBlockSession, virtualBlockSession.isMaterialized {
            // The created block's cell has taken first responder over from this placeholder;
            // the placeholder row can now be removed without touching the keyboard.
            virtualBlockSession.completeFocusHandoff()
        }
        let configuration = accessoryConfiguration(using: textView)

        collectionController.blockDidFinishEditing()
        accessoryViewStateManager.didEndEditing(with: configuration)
    }

    @MainActor
    private func textViewDidChangeCaretPosition(textView: UITextView, range: NSRange) {
        accessoryViewStateManager.selectionDidChange(range: range)
        // A pending focus for a not-yet-created block would shadow the focus handoff to the
        // real block set during materialization.
        guard !isVirtualUnmaterialized else { return }
        // Same for the old id of an in-flight identity fork; after the rebind info.id is the
        // new id and caret tracking resumes.
        guard pendingForkOldId != info.id else { return }
        cursorManager.blockFocus = BlockFocus(id: info.id, position: .at(range))
//        cursorManager.didChangeCursorPosition(at: data.info.id, position: .at(range)) // DO WE NEED IT? WHY?
    }

    private func toggleCheckBox() {
        guard !isVirtualUnmaterialized else { return }
        guard let content = info.textContent else { return }
        actionHandler.checkbox(selected: !content.checked, blockId: info.id)
    }

    private func toggleDropdownView() {
        guard !isVirtualUnmaterialized else { return }
        info.toggle()
        actionHandler.toggle(blockId: info.id)
        viewModel.map { collectionController.reconfigure(items: [.block($0)]) }
    }

    private func objectDetails(forObjectId objectId: String) async throws -> ObjectDetails {
        if let cached = document.detailsStorage.get(id: objectId) {
            return cached
        }
        let results = try await searchService.searchObjects(spaceId: document.spaceId, objectIds: [objectId])
        guard let details = results.first else {
            throw CommonError.undefined
        }
        return details
    }

    private func parsedLocalObjectId(from url: URL) -> String? {
        // Web link form (https://object.any.coop/...) is what desktop and iOS share/copy generate,
        // so it covers nearly every real paste. Fall back to anytype:// deep link form only if the
        // web parser didn't recognize the URL at all (rare edge case — internal scheme rarely ends
        // up on the clipboard).
        let candidate: (objectId: String, spaceId: String)? = {
            if let universalLink = universalLinkParser.parse(url: url) {
                if case let .object(objectId, spaceId, _, _) = universalLink {
                    return (objectId, spaceId)
                }
                return nil
            }
            if let deepLink = deepLinkParser.parse(url: url),
               case let .object(objectId, spaceId, _, _) = deepLink {
                return (objectId, spaceId)
            }
            return nil
        }()
        guard let candidate,
              candidate.spaceId == document.spaceId,
              candidate.objectId != document.objectId else {
            return nil
        }
        return candidate.objectId
    }
}

extension TextBlockActionHandler: AccessoryViewOutput {
    @MainActor
    func showLinkToSearch(range: NSRange, text: NSAttributedString) {
        guard !isVirtualUnmaterialized else { return }
        linkToSearchHelper.showLinkToSearch(
            range: range,
            text: text,
            delegate: self,
            document: document,
            markupChanger: markupChanger,
            info: info
        )
    }
    
    // MARK: - LinkToSearchDelegate
    
    func updateTextForLinkToObject(newText: NSAttributedString, range: NSRange, originalText: NSAttributedString) {
        setNewTextSync(attributedString: newText)
    }
    
    func updateTextForLinkToUrl(newText: NSAttributedString, range: NSRange, originalText: NSAttributedString) {
        setNewTextSync(attributedString: newText)
    }
    
    func removeLink(markup: MarkupType, newText: NSAttributedString, range: NSRange, originalText: NSAttributedString) {
        setNewTextSync(attributedString: newText)
    }
    
    func openLinkToObject(data: LinkToObjectSearchModuleData) {
        openLinkToObject(data)
    }
    
    func setNewText(attributedString: SafeNSAttributedString) async throws {
        resetSubject.send(attributedString.value)
        if try await carryOrSync(attributedString.value, focusAt: endOfTextFocus(attributedString.value)) { return }
        try await actionHandler.changeText(attributedString, blockId: info.id)

        viewModel.map { collectionController.itemDidChangeFrame(item: .block($0)) }
    }

    func changeText(attributedString: SafeNSAttributedString) {
        Task { @MainActor in
            if try await carryOrSync(attributedString.value, focusAt: nil) { return }
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
        // setNewText normally materializes first; this covers actions reached without it.
        _ = try await carryOrSync(textView?.attributedText ?? NSAttributedString(), focusAt: nil)
        try await slashMenuActionHandler.handle(
            action,
            textView: textView,
            blockInformation: info,
            modifiedStringHandler: { [weak resetSubject] modifiedAttributedString in
                resetSubject?.send(modifiedAttributedString?.value)
            }
        )
    }
    
    func didSelectEditButton() {
        if isVirtualUnmaterialized {
            Task { @MainActor in
                try await materializeVirtualBlock(carrying: NSAttributedString(), focusAt: nil)
                onEnterSelectionMode(info)
            }
            return
        }
        onEnterSelectionMode(info)
    }

    func didSelectShowStyleMenu() {
        if isVirtualUnmaterialized {
            Task { @MainActor in
                try await materializeVirtualBlock(carrying: NSAttributedString(), focusAt: nil)
                onShowStyleMenu(info)
            }
            return
        }
        onShowStyleMenu(info)
    }

    func didSelectUndoRedo() {
        onSelectUndoRedo()
    }

    func didSelectDeleteBlock() {
        if isVirtualUnmaterialized {
            virtualBlockSession?.dismissAndFocusPreviousBlock()
            return
        }
        onDeleteBlock(info)
    }

    func didSelectIndentLeft() {
        guard !isVirtualUnmaterialized else { return }
        onIndentLeft(info)
    }

    func didSelectIndentRight() {
        guard !isVirtualUnmaterialized else { return }
        onIndentRight(info)
    }

    private func setNewTextSync(attributedString: NSAttributedString) {
        Task { try await setNewText(attributedString: attributedString.sendable()) }
    }

    /// Like `setNewTextSync`, but after the write refreshes the live cell for the current block id.
    /// The paste-menu callbacks run on the pre-fork handler: if the empty-block identity fork or the
    /// virtual-placeholder materialization has swapped this block's identity, `setNewText`'s
    /// `resetSubject` only reaches this handler's now-replaced cell. Reconfiguring the live cell from
    /// the freshly written model both shows the new value and re-syncs its text view, so the next
    /// keystroke cannot read the stale link back and overwrite the plain text.
    private func setNewTextRefreshingLiveBlock(attributedString: NSAttributedString) {
        Task { @MainActor in
            try await setNewText(attributedString: attributedString.sendable())
            reconfigureLiveBlock(info.id)
        }
    }
}
