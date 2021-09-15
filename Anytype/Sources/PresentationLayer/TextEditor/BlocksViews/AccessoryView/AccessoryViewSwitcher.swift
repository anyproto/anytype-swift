import UIKit
import BlocksModels

protocol AccessoryViewSwitcherProtocol: EditorAccessoryViewDelegate {
    func showURLInput(url: URL?)
    
    func didBeginEditing(data: AccessoryViewSwitcherData)
        
    func textDidChange()
    func textWillChange(replacementText: String, range: NSRange)
}

extension AccessoryViewSwitcher {
    enum ViewType {
        case none
        case `default`(EditorAccessoryView)
        case mention(MentionView)
        case slashMenu(SlashMenuView)
        case urlInput(URLInputAccessoryView)
    
        var view: UIView? {
            switch self {
            case .default(let view):
                return view
            case .mention(let view):
                return view
            case .slashMenu(let view):
                return view
            case .urlInput(let view):
                return view
            case .none:
                return nil
            }
        }
    }
}

final class AccessoryViewSwitcher: AccessoryViewSwitcherProtocol {
    private var displayAcessoryViewTask = DispatchWorkItem {}
    private(set) var accessoryViewTriggerSymbolPosition: UITextPosition?
    
    private var displayedView = ViewType.none
    
    private var latestTextViewTextChange: TextViewTextChangeType?
    
    private let accessoryView: EditorAccessoryView
    private let mentionsView: MentionView
    private let slashMenuView: SlashMenuView
    private lazy var urlInputView = buildURLInputView()
    
    private let handler: EditorActionHandlerProtocol
    
    private var data: AccessoryViewSwitcherData?
    
    init(
        mentionsView: MentionView,
        slashMenuView: SlashMenuView,
        accessoryView: EditorAccessoryView,
        handler: EditorActionHandlerProtocol
    ) {
        self.slashMenuView = slashMenuView
        self.accessoryView = accessoryView
        self.mentionsView = mentionsView
        self.handler = handler
        
        setupDismissHandlers()
    }

    // MARK: - Public methods
    func showMentionsView(textView: UITextView) {
        showAccessoryView(.mention(mentionsView))
    }
    
    func showSlashMenuView(textView: UITextView) {
        showAccessoryView(.slashMenu(slashMenuView))
    }
    
    func didBeginEditing(data: AccessoryViewSwitcherData) {
        self.data = data
        
        accessoryView.update(information: data.information, textView: data.textView)
        changeAccessoryView(accessoryView)
        
        slashMenuView.update(block: data.block)
    }

    func textWillChange(replacementText: String, range: NSRange) {
        guard let data = data else { return }
        
        latestTextViewTextChange = data.textView.textView.textChangeType(
            changeTextRange: range,
            replacementText: replacementText
        )
    }

    func textDidChange() {
        displayAcessoryViewTask.cancel()
        if isFilterableViewCurrentlyVisible() {
            setFilterTextToView()
            return
        }
        
        switch latestTextViewTextChange {
        case .typingSymbols:
            displaySlashOrMentionIfNeeded()
        case .none, .deletingSymbols:
            return
        }
    }
    
    func showURLInput(url: URL?) {
        urlInputView.updateUrl(url)
        showAccessoryView(.urlInput(urlInputView))
        urlInputView.urlInputView.textField.becomeFirstResponder()
        cleanupDisplayedView()
    }
    
    // MARK: - Private methods
    private func cleanupDisplayedView() {
        slashMenuView.restoreDefaultState()
        
        displayedView = .none
        accessoryViewTriggerSymbolPosition = nil
    }
    
    private func showAccessoryView(_ view: ViewType) {
        guard let textView = data?.textView.textView else { return }
        
        displayedView = view
        accessoryViewTriggerSymbolPosition = textView.caretPosition()
        
        changeAccessoryView(view.view)
        
        if let view = view.view as? DismissableInputAccessoryView {
            view.didShow(from: textView)
        }
    }
    
    private func changeAccessoryView(_ accessoryView: UIView?) {
        guard let accessoryView = accessoryView,
              let textView = data?.textView.textView,
              textView.inputAccessoryView != accessoryView else {
            return
        }
        
        textView.inputAccessoryView = accessoryView
        
        accessoryView.transform = CGAffineTransform(translationX: 0, y: accessoryView.bounds.size.height)
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            accessoryView.transform = .identity
            textView.reloadInputViews()
            textView.window?.layoutIfNeeded()
        }
    }
    
    private func showAccessoryViewWithDelay(
        _ accessoryView: ViewType
    ) {
        displayAcessoryViewTask = DispatchWorkItem { [weak self] in
            self?.showAccessoryView(accessoryView)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: displayAcessoryViewTask)
    }
    
    private func isFilterableViewCurrentlyVisible() -> Bool {
        if case .default = displayedView, accessoryView.window.isNotNil {
            return false
        }
        return true
    }
    
    private func setFilterTextToView() {
        guard let filterText = filterText() else { return }
        guard let textView = data?.textView.textView else { return }
        guard let displayedView = displayedView.view as? FilterableItemsView else { return }
        
        displayedView.setFilterText(filterText: filterText)

        if displayedView.shouldContinueToDisplayView() == false {
            cleanupDisplayedView()
            showAccessoryView(.default(accessoryView))
            return
        }
        guard let triggerSymbolPosition = accessoryViewTriggerSymbolPosition,
              let caretPosition = textView.caretPosition(),
              textView.compare(triggerSymbolPosition, to: caretPosition) == .orderedDescending else {
            return
        }
        cleanupDisplayedView()
        showAccessoryView(.default(accessoryView))
    }
    
    private func filterText() -> String? {
        guard let textView = data?.textView.textView else { return nil }
        
        guard let caretPosition = textView.caretPosition(),
              let triggerSymbolPosition = accessoryViewTriggerSymbolPosition,
              let range = textView.textRange(from: triggerSymbolPosition, to: caretPosition) else {
            return nil
        }
        return textView.text(in: range)
    }
    
    private func displaySlashOrMentionIfNeeded() {
        guard let textView = data?.textView.textView else { return }
        guard let data = data, data.information.content.type != .text(.title) else { return }
        guard let textBeforeCaret = textView.textBeforeCaret() else { return }
        
        if textBeforeCaret.hasSuffix("/") {
            showAccessoryViewWithDelay(.slashMenu(slashMenuView))
        } else if textBeforeCaret.hasSuffix("@") {
            showAccessoryViewWithDelay(.mention(mentionsView))
        }
    }
    
    private func setupDismissHandlers() {
        let dismissActionsMenu = { [weak self] in
            guard let self = self else { return }
            self.cleanupDisplayedView()
            self.showAccessoryView(.default(self.accessoryView))
        }

        mentionsView.dismissHandler = dismissActionsMenu
        slashMenuView.dismissHandler = dismissActionsMenu
    }
    
    // MARK: - Views
    func buildURLInputView() -> URLInputAccessoryView {
        let dismissHandler = { [weak self] in
            guard let self = self, let textView = self.data?.textView.textView else { return }
            textView.becomeFirstResponder()
            self.showAccessoryView(.default(self.accessoryView))
        }
        let urlInputView = URLInputAccessoryView() { [weak self] url in
            guard let self = self, let data = self.data else { return }
            
            let range = data.textView.textView.selectedRange
            self.handler.handleAction(
                .setLink(data.text.attrString, url, range),
                blockId: data.information.id
            )
            dismissHandler()
        }
        urlInputView.dismissHandler = dismissHandler
        return urlInputView
    }
}

// MARK: - MentionViewDelegate

extension AccessoryViewSwitcher: MentionViewDelegate {
    func selectMention(_ mention: MentionObject) {
        guard let data = data else { return }
        
        guard let mentionSymbolPosition = accessoryViewTriggerSymbolPosition,
              let previousToMentionSymbol = data.textView.textView.position(
                from: mentionSymbolPosition,
                offset: -1
            ),
              let caretPosition = data.textView.textView.caretPosition() else {
            return
        }
        
        data.textView.textView.insert(
            mention,
            from: previousToMentionSymbol,
            to: caretPosition,
            font: data.text.anytypeFont
        )

        handler.handleAction(
            .textView(
                action: .changeText(data.textView.textView.attributedText),
                block: data.block
            ),
            blockId: data.information.id
        )
    }
}
