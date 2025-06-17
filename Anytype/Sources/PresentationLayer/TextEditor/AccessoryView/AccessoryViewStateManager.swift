import Foundation
import Services
import UIKit

@MainActor
protocol AccessoryViewStateManager {
    func willBeginEditing(with configuration: TextViewAccessoryConfiguration)
    func didBeginEdition(with configuration: TextViewAccessoryConfiguration)
    func didEndEditing(with configuration: TextViewAccessoryConfiguration)
    func textDidChange(changeType: TextChangeType)
    func selectionDidChange(range: NSRange)
}

enum AccessoryViewInputState {
    case none
    case search
}

@MainActor
protocol AccessoryViewOutput: AnyObject {
    var accessoryState: AccessoryViewInputState { get set }
    
    func showLinkToSearch(range: NSRange, text: NSAttributedString)
    func setNewText(attributedString: SafeNSAttributedString) async throws
    func didSelectAddMention(
        _ mention: MentionObject,
        at position: Int,
        attributedString: SafeNSAttributedString
    ) async throws
    
    func didSelectSlashAction(
        _ action: SlashAction,
        at position: Int,
        textView: UITextView?
    ) async throws
    
    func didSelectEditButton()
    func didSelectShowStyleMenu()
}

@MainActor
final class AccessoryViewStateManagerImpl: AccessoryViewStateManager, CursorModeAccessoryViewDelegate {
    private var configuration: TextViewAccessoryConfiguration?
    private(set) var triggerSymbolPosition: UITextPosition?
    
    private let document: any BaseDocumentProtocol
    private let switcher: AccessoryViewSwitcher
    private let markupChanger: any BlockMarkupChangerProtocol
    
    let cursorModeViewModel: CursorModeAccessoryViewModel
    let slashMenuViewModel: SlashMenuViewModel
    let mentionsViewModel: MentionsViewModel
    let markupAccessoryViewModel: MarkupAccessoryViewModel

    init(
        document: some BaseDocumentProtocol,
        switcher: AccessoryViewSwitcher,
        markupChanger: some BlockMarkupChangerProtocol,
        cursorModeViewModel: CursorModeAccessoryViewModel,
        slashMenuViewModel: SlashMenuViewModel,
        mentionsViewModel: MentionsViewModel,
        markupAccessoryViewModel: MarkupAccessoryViewModel
    ) {
        self.document = document
        self.switcher = switcher
        self.markupChanger = markupChanger
        
        self.cursorModeViewModel = cursorModeViewModel
        self.slashMenuViewModel = slashMenuViewModel
        self.mentionsViewModel = mentionsViewModel
        self.markupAccessoryViewModel = markupAccessoryViewModel
        
        markupAccessoryViewModel.onMarkupTap = { [weak self] markup in
            Task { @MainActor in
                try await self?.handle(markup)
            }
        }
        
        markupAccessoryViewModel.onColorSelection = { [weak self] selectedColor in
            Task { @MainActor in
                try await self?.handle(selectedColor)
            }
        }
        
        cursorModeViewModel.onActionHandler = { [weak self] action in
            self?.handle(action)
        }
        
        slashMenuViewModel.onSlashAction = { [weak self] action in
            self?.handle(action)
        }
    }
    
    // MARK: - AccessoryViewStateManager
    func willBeginEditing(with configuration: TextViewAccessoryConfiguration) {

    }
    
    func didBeginEdition(with configuration: TextViewAccessoryConfiguration) {
        // Clear existing configuration and state
        self.configuration?.textView.inputAccessoryView = nil
        self.configuration?.output?.accessoryState = .none
        self.configuration = nil
        
        switcher.clearAccessory()
        
        
        switcher.update(with: configuration)
        
        // Cursor mode
        cursorModeViewModel.update(with: configuration)
        
        // Slash menu
        let restrictions = BlockRestrictionsBuilder.build(contentType: configuration.contentType)
        slashMenuViewModel.update(
            with: document.spaceId,
            restrictions: restrictions,
            relations: document.parsedProperties.installed
        )
        
        // Markup menu
        markupAccessoryViewModel.update(configuration)
        
        if configuration.textView.selectedRange.length != .zero {
            switcher.showMarkupView()
        } else {
            switcher.showDefaultView()
        }
        
        self.configuration = configuration
    }
    
    func didEndEditing(with configuration: TextViewAccessoryConfiguration) {
        // Clear existing configuration and state
        self.configuration?.textView.inputAccessoryView = nil
        self.configuration?.output?.accessoryState = .none
        self.configuration = nil
        
        switcher.clearAccessory()
        switcher.update(with: configuration)
        
        // Cursor mode
        cursorModeViewModel.update(with: configuration)
        
        // Slash menu
        let restrictions = BlockRestrictionsBuilder.build(contentType: configuration.contentType)
        slashMenuViewModel.update(
            with: document.spaceId,
            restrictions: restrictions,
            relations: document.parsedProperties.installed
        )
        
        // Markup menu
        markupAccessoryViewModel.update(configuration)
        
        if configuration.textView.selectedRange.length != .zero {
            switcher.showMarkupView()
        } else {
            switcher.showDefaultView()
        }
        
        self.configuration = configuration
    }

    func textDidChange(changeType: TextChangeType) {
        switch switcher.activeView {
        case .`default`, .changeType:
            updateDefaultView()
            triggerTextActions(changeType: changeType)
        case .mention, .slashMenu:
            setTextToSlashOrMention()
        case .none, .markup:
            break
        }
    }

    func selectionDidChange(range: NSRange) {
        markupAccessoryViewModel.updateRange(range: range)
        if case .markup = switcher.activeView {
            if range.length == 0 {
                updateDefaultView()
            } else {
                markupAccessoryViewModel.updateRange(range: range)
            }
        } else if range.length > 0 {
            switcher.showMarkupView()
        }
    }
    
    // MARK: - View Delegate

    func showSlashMenuView() {
        guard let textView = configuration?.textView else { return }
        triggerSymbolPosition = textView.caretPosition
        slashMenuViewModel.setFilterText(filterText: "")
        
        switcher.showSlashMenuView()
    }
    
    func showMentionsView() {
        guard let textView = configuration?.textView else { return }
        triggerSymbolPosition = textView.caretPosition
        mentionsViewModel.setFilterString("")
        switcher.showMentionsView()
    }
    
    // MARK: - Private
    private func setTextToSlashOrMention() {
        guard let filterText = searchText() else { return }

        switch switcher.activeView {
        case .mention:
            mentionsViewModel.setFilterString(filterText)
            dismissViewIfNeeded()
        case .slashMenu:
            slashMenuViewModel.setFilterText(filterText: filterText)
            dismissViewIfNeeded()
        default:
            break
        }
    }
    
    private func searchText() -> String? {
        guard let textView = configuration?.textView else { return nil }
        
        guard let caretPosition = textView.caretPosition,
              let triggerSymbolPosition = triggerSymbolPosition,
              let range = textView.textRange(from: triggerSymbolPosition, to: caretPosition) else {
            return nil
        }
        return textView.text(in: range)
    }
    
    private func updateDefaultView() {
        switcher.showDefaultView()
    }
    
    private func triggerTextActions(changeType: TextChangeType) {
        guard changeType == .typingSymbols else { return }
        
        displaySlashOrMentionIfNeeded()
    }
    
    private var isTriggerSymbolDeleted: Bool {
        guard let triggerSymbolPosition = triggerSymbolPosition,
              let textView = configuration?.textView,
              let caretPosition = textView.caretPosition else {
            return false
        }

        return textView.compare(triggerSymbolPosition, to: caretPosition) == .orderedDescending
    }
    
    private var searchContainsMultipleSpaces: Bool {
        guard let text = searchText() else { return false }
        let spaces = text.filter { $0 == " " }.count
        return spaces > 1
    }
    
    func dismissViewIfNeeded(forceDismiss: Bool = false) {
        if forceDismiss || isTriggerSymbolDeleted || searchContainsMultipleSpaces {
            configuration?.output?.accessoryState = .none
            switcher.showDefaultView()
        }
    }

    private func displaySlashOrMentionIfNeeded() {
        guard let configuration,
              isAvailableBlockContentType(configuration),
              let textBeforeCaret = configuration.textView.textBeforeCaret,
              let caretPosition = configuration.textView.caretPosition else {
            
            return
        }

        let carretOffset = configuration.textView.offsetFromBegining(caretPosition)
        let prependSpace = carretOffset > 1 // We need whitespace before / or @ if it is not 1st symbol

        if textBeforeCaret.hasSuffix(TextTriggerSymbols.slashMenu) && configuration.usecase != .simpleTable {
            showSlashMenuView()
        } else if textBeforeCaret.hasSuffix(TextTriggerSymbols.mention(prependSpace: prependSpace)) {
            showMentionsView()
        } else {
            return
        }
        
        configuration.output?.accessoryState = .search
        triggerSymbolPosition = configuration.textView.caretPosition
    }
    
    private func attributedStringWithoutSearchSymbols() -> (NSAttributedString, Int)? {
        guard let configuration,
              let mentionSymbolPosition = triggerSymbolPosition,
              let newMentionPosition = configuration.textView.position(from: mentionSymbolPosition, offset: -1),
              let caretPosition = configuration.textView.caretPosition else { return nil }
        
        let startPosition = configuration.textView.offsetFromBegining(newMentionPosition)
        let caretOffsetFromStart = configuration.textView.offset(from: newMentionPosition, to: caretPosition)
        
        let mutableString = NSMutableAttributedString(attributedString: configuration.textView.attributedText)
        mutableString.replaceCharacters(in: .init(location: startPosition, length: caretOffsetFromStart), with: "")
        
        return (mutableString, startPosition)
    }
}

// MARK: - SlashMenuHandler
extension AccessoryViewStateManagerImpl {
    func handle(_ action: SlashAction){
        Task { @MainActor in
            guard let (attrString, index) = attributedStringWithoutSearchSymbols(),
                  let configuration else { return }
            
            try await configuration.output?.setNewText(attributedString: attrString.sendable())
            
            guard let triggerSymbolPosition,
                  configuration.textView.textRange(
                    from: triggerSymbolPosition,
                    to: triggerSymbolPosition
                  ).isNotNil else { return }
            
            let nsrange = NSRange(location: configuration.textView.offsetFromBegining(triggerSymbolPosition) - 1, length: 0)
            
            
            configuration.textView.selectedRange = nsrange
            
            try await configuration.output?.didSelectSlashAction(
                action,
                at: index,
                textView: configuration.textView
            )
            
            switcher.showDefaultView()
            slashMenuViewModel.setFilterText(filterText: "")
            configuration.output?.accessoryState = .none
            
            self.triggerSymbolPosition = nil
        }
    }
}

// MARK: - MentionViewDelegate
extension AccessoryViewStateManagerImpl: MentionViewDelegate {
    func selectMention(_ mention: MentionObject) {
        guard let (attrString, index) = attributedStringWithoutSearchSymbols(),
              let configuration else { return }
        
        Task { @MainActor in
            try await configuration.output?.didSelectAddMention(mention, at: index, attributedString: attrString.sendable())
            
            switcher.showDefaultView()
            mentionsViewModel.setFilterString("")
            configuration.output?.accessoryState = .none
            
            AnytypeAnalytics.instance().logChangeTextStyle(
                markupType: .mention(MentionObject.noDetails(blockId: "")),
                objectType: mention.details.objectType.isDateType ? .date : .custom
            )
        }
    }
}

// MARK: - Markup Action handler
extension AccessoryViewStateManagerImpl {
    func handle(_ markup: MarkupAccessoryViewModel.MarkupKind) async throws {
        guard let configuration else { return }
        
        switch markup {
        case .link:
            configuration.output?.showLinkToSearch(
                range: configuration.textView.selectedRange,
                text: configuration.textView.attributedText
            )
        case .color:
            markupAccessoryViewModel.showColorView.toggle()
        case let .fontStyle(fontMarkup):
            let newAttributedString = markupChanger.toggleMarkup(
                configuration.textView.attributedText,
                markup: fontMarkup.markupType,
                range: configuration.textView.selectedRange,
                contentType: configuration.contentType
            ).sendable()
            
            try await configuration.output?.setNewText(attributedString: newAttributedString)
        }
    }
    
    func handle(_ colorItem: ColorView.ColorItem) async throws {
        guard let configuration else { return }
        let markup: MarkupType
        
        switch colorItem {
        case .text(let blockColor):
            markup = .textColor(blockColor.middleware)
        case .background(let blockBackgroundColor):
            markup = .backgroundColor(blockBackgroundColor.middleware)
        }
        
        let newAttributedString = markupChanger.toggleMarkup(
            configuration.textView.attributedText,
            markup: markup,
            range: configuration.textView.selectedRange,
            contentType: configuration.contentType
        ).sendable()
        
        try await configuration.output?.setNewText(attributedString: newAttributedString)
    }
}

// MARK: - CursorMode Action handler
extension AccessoryViewStateManagerImpl {
    func handle(_ action: CursorModeAccessoryViewAction) {
        logEvent(for: action)
        
        switch action {
        case .showStyleMenu:
            configuration?.output?.didSelectShowStyleMenu()
        case .keyboardDismiss:
            UIApplication.shared.hideKeyboard()
        case .mention:
            configuration.map {
                $0.textView.insertStringAfterCaret(
                    TextTriggerSymbols.mention(prependSpace: shouldPrependSpace(textView: $0.textView))
                )
            }
            showMentionsView()
            configuration?.output?.accessoryState = .search
        case .slashMenu:
            configuration?.textView.insertStringAfterCaret(TextTriggerSymbols.slashMenu)
            showSlashMenuView()
            slashMenuViewModel.setFilterText(filterText: "")
            configuration?.output?.accessoryState = .search
        case .editingMode:
            configuration?.output?.didSelectEditButton()
        }
    }
    
    private func shouldPrependSpace(textView: UITextView) -> Bool {
        let carretInTheBeginingOfDocument = textView.isCarretInTheBeginingOfDocument
        let haveSpaceBeforeCarret = textView.textBeforeCaret?.last == " "
        
        return !(carretInTheBeginingOfDocument || haveSpaceBeforeCarret)
    }
    
    private func isAvailableBlockContentType(_ configuration: TextViewAccessoryConfiguration) -> Bool {
        configuration.contentType != .text(.title) && configuration.contentType != .text(.description)
    }
    
    private func logEvent(for action: CursorModeAccessoryViewAction) {
        switch action {
        case .slashMenu:
            AnytypeAnalytics.instance().logKeyboardBarSlashMenu()
        case .keyboardDismiss:
            AnytypeAnalytics.instance().logKeyboardBarHideKeyboardMenu()
        case .showStyleMenu:
            AnytypeAnalytics.instance().logKeyboardBarStyleMenu()
        case .mention:
            AnytypeAnalytics.instance().logKeyboardBarMentionMenu()
        case .editingMode:
            AnytypeAnalytics.instance().logKeyboardBarSelectionMenu()
        }
    }
}
