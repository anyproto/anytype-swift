import UIKit
import BlocksModels

protocol AccessoryViewSwitcherProtocol: EditorAccessoryViewDelegate {
    func showURLInput(textView: UITextView, url: URL?)
    
    func didBeginEditing(data: AccessoryViewSwitcherData)
        
    func textDidChange(textView: UITextView)
    func textWillChange(textView: UITextView, replacementText: String, range: NSRange)
}

final class AccessoryViewSwitcher: AccessoryViewSwitcherProtocol {
    private var displayAcessoryViewTask = DispatchWorkItem {}
    private(set) var accessoryViewTriggerSymbolPosition: UITextPosition?
    
    private weak var displayedView: (DismissableInputAccessoryView & FilterableItemsView)?
    
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
        showAccessoryView(accessoryView: mentionsView, textView: textView)
    }
    
    func showSlashMenuView(textView: UITextView) {
        showAccessoryView(accessoryView: slashMenuView, textView: textView)
    }
    
    func didBeginEditing(data: AccessoryViewSwitcherData) {
        self.data = data
        
        accessoryView.update(information: data.information, textView: data.textView)
        changeAccessoryView(accessoryView, in: data.textView.textView)
        
        slashMenuView.update(block: data.block)
    }

    func textWillChange(textView: UITextView, replacementText: String, range: NSRange) {
        latestTextViewTextChange = textView.textChangeType(
            changeTextRange: range,
            replacementText: replacementText
        )
    }

    func textDidChange(textView: UITextView) {
        displayAcessoryViewTask.cancel()
        switch latestTextViewTextChange {
        case .none:
            return
        case .deletingSymbols:
            handleSymbolsDeleted(in: textView)
        case .typingSymbols:
            handleSymbolsTyped(in: textView)
        }
    }
    
    func showURLInput(textView: UITextView, url: URL?) {
        urlInputView.updateUrl(url)
        changeAccessoryView(urlInputView, in: textView)
        urlInputView.urlInputView.textField.becomeFirstResponder()
        cleanupDisplayedView()
    }
    
    // MARK: - Private methods
    private func cleanupDisplayedView() {
        slashMenuView.restoreDefaultState()
        
        displayedView = nil
        accessoryViewTriggerSymbolPosition = nil
    }
    
    private func showAccessoryView(
        accessoryView: (DismissableInputAccessoryView & FilterableItemsView)?,
        textView: UITextView
    ) {
        changeAccessoryView(accessoryView, in: textView)
        displayedView = accessoryView
        accessoryView?.didShow(from: textView)
        accessoryViewTriggerSymbolPosition = textView.caretPosition()
    }
    
    private func changeAccessoryView(_ accessoryView: UIView?, in textView: UITextView) {
        guard let accessoryView = accessoryView, textView.inputAccessoryView != accessoryView else {
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
        _ accessoryView: (DismissableInputAccessoryView & FilterableItemsView)?,
        in textView: UITextView
    ) {
        displayAcessoryViewTask = DispatchWorkItem { [weak self] in
            self?.showAccessoryView(
                accessoryView: accessoryView,
                textView: textView
            )
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: displayAcessoryViewTask)
    }
    
    private func isFilterableViewCurrentlyVisible() -> Bool {
        guard let accessoryView = displayedView, accessoryView.window.isNotNil else {
            return false
        }
        return true
    }
    
    private func filterText(from textView: UITextView) -> String? {
        guard let caretPosition = textView.caretPosition(),
              let triggerSymbolPosition = accessoryViewTriggerSymbolPosition,
              let range = textView.textRange(from: triggerSymbolPosition, to: caretPosition) else {
            return nil
        }
        return textView.text(in: range)
    }
    
    private func dismissDisplayedViewIfNeeded(textView: UITextView) {
        if displayedView?.shouldContinueToDisplayView() == false {
            cleanupDisplayedView()
            changeAccessoryView(accessoryView, in: textView)
            return
        }
        guard let triggerSymbolPosition = accessoryViewTriggerSymbolPosition,
              let caretPosition = textView.caretPosition(),
              textView.compare(triggerSymbolPosition, to: caretPosition) == .orderedDescending else {
            return
        }
        cleanupDisplayedView()
        changeAccessoryView(accessoryView, in: textView)
    }
    
    private func setFilterTextToView(in textView: UITextView) {
        guard let filterText = filterText(from: textView) else { return }
        displayedView?.setFilterText(filterText: filterText)
        dismissDisplayedViewIfNeeded(textView: textView)
    }
    
    private func handleSymbolsTyped(in textView: UITextView) {
        if isFilterableViewCurrentlyVisible() {
            setFilterTextToView(in: textView)
        } else {
            displaySlashOrMentionIfNeeded(textView: textView)
        }
    }
    
    private func displaySlashOrMentionIfNeeded(textView: UITextView) {
        guard let data = data, data.information.content.type != .text(.title) else { return }
        guard let textBeforeCaret = textView.textBeforeCaret() else { return }
        
        if textBeforeCaret.hasSuffix("/") {
            showAccessoryViewWithDelay(slashMenuView, in: textView)
        } else if textBeforeCaret.hasSuffix("@") {
            showAccessoryViewWithDelay(mentionsView, in: textView)
        }
    }
    
    private func handleSymbolsDeleted(in textView: UITextView) {
        guard isFilterableViewCurrentlyVisible() else { return }
        setFilterTextToView(in: textView)
    }
    
    private func setupDismissHandlers() {
        let dismissActionsMenu = { [weak self] in
            guard let self = self else {
                return
            }
            self.cleanupDisplayedView()

            
            if let textView = self.data?.textView.textView {
                self.changeAccessoryView(self.accessoryView, in: textView)
            }
        }

        mentionsView.dismissHandler = dismissActionsMenu
        slashMenuView.dismissHandler = dismissActionsMenu
    }
    
    // MARK: - Views
    func buildURLInputView() -> URLInputAccessoryView {
        let dismissHandler = { [weak self] in
            guard let self = self, let textView = self.data?.textView.textView else { return }
            textView.becomeFirstResponder()
            self.changeAccessoryView(self.accessoryView, in: textView)
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
