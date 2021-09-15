import UIKit
import BlocksModels


protocol AccessoryViewSwitcherDelegate: AnyObject {
    // mention events
    func mentionSelected( _ mention: MentionObject, from: UITextPosition, to: UITextPosition)
    
    /// Delegate method called after url was entered from accessory view
    func didEnterURL(_ url: URL?)
}

protocol AccessoryViewSwitcherProtocol: EditorAccessoryViewDelegate {
    func showURLInput(textView: UITextView, url: URL?)
    
    func didBeginEditing(
        textView: CustomTextView,
        delegate: AccessoryViewSwitcherDelegate & TextViewDelegate,
        information: BlockInformation
    )
    
    func textDidChange(textView: UITextView)
    func textWillChange(textView: UITextView, replacementText: String, range: NSRange)
}

final class AccessoryViewSwitcher: AccessoryViewSwitcherProtocol {
    private var displayAcessoryViewTask: DispatchWorkItem?
    private(set) var accessoryViewTriggerSymbolPosition: UITextPosition?
    
    private weak var displayedView: (DismissableInputAccessoryView & FilterableItemsView)?
    
    private weak var textView: UITextView?
    private weak var delegate: AccessoryViewSwitcherDelegate?
    private var latestTextViewTextChange: TextViewTextChangeType?
    
    private let accessoryView: EditorAccessoryView
    private let mentionsView: MentionView
    private let slashMenuView: SlashMenuView
    private lazy var urlInputView = buildURLInputView()
    
    init(
        mentionsView: MentionView,
        slashMenuView: SlashMenuView,
        accessoryView: EditorAccessoryView
    ) {
        self.slashMenuView = slashMenuView
        self.accessoryView = accessoryView
        self.mentionsView = mentionsView
        
        setupDismissHandlers()
    }

    // MARK: - Public methods
    func showMentionsView(textView: UITextView) {
        showAccessoryView(accessoryView: mentionsView, textView: textView)
    }
    
    func showSlashMenuView(textView: UITextView) {
        showAccessoryView(accessoryView: slashMenuView, textView: textView)
    }
    
    func didBeginEditing(
        textView: CustomTextView,
        delegate: AccessoryViewSwitcherDelegate & TextViewDelegate,
        information: BlockInformation
    ) {
        self.delegate = delegate
        self.textView = textView.textView
        
        accessoryView.update(information: information, textView: textView)
        changeAccessoryView(accessoryView, in: textView.textView)
        
        let restrictions = BlockRestrictionsFactory().makeRestrictions(for: information.content.type)
        slashMenuView.menuItems = SlashMenuItemsBuilder(restrictions: restrictions)
            .slashMenuItems()
    }

    func textWillChange(textView: UITextView, replacementText: String, range: NSRange) {
        latestTextViewTextChange = textView.textChangeType(
            changeTextRange: range,
            replacementText: replacementText
        )
    }

    func textDidChange(textView: UITextView) {
        displayAcessoryViewTask?.cancel()
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
    
    private func createDelayedAcessoryViewTask(
        accessoryView: (DismissableInputAccessoryView & FilterableItemsView)?,
        textView: UITextView
    ) {
        let task = DispatchWorkItem(block: { [weak self] in
            self?.showAccessoryView(
                accessoryView: accessoryView,
                textView: textView
            )
        })
        displayAcessoryViewTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: task)
    }
    
    private func isFilterableViewCurrentlyVisible() -> Bool {
        guard let accessoryView = displayedView,
              accessoryView.window.isNotNil else {
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
    
    private func displayFilterableViewIfNeeded(textView: UITextView) {
        guard let textBeforeCaret = textView.textBeforeCaret() else { return }
        if textBeforeCaret.hasSuffix("/") {
            createDelayedAcessoryViewTask(
                accessoryView: slashMenuView,
                textView: textView
            )
        } else if textBeforeCaret.hasSuffix("@") {
            createDelayedAcessoryViewTask(
                accessoryView: mentionsView,
                textView: textView
            )
        }
    }
    
    private func handleSymbolsTyped(in textView: UITextView) {
        if isFilterableViewCurrentlyVisible() {
            setFilterTextToView(in: textView)
        } else {
            displayFilterableViewIfNeeded(textView: textView)
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

            self.textView.flatMap { self.changeAccessoryView(self.accessoryView, in: $0) }
        }

        mentionsView.dismissHandler = dismissActionsMenu
        slashMenuView.dismissHandler = dismissActionsMenu
    }
    
    // MARK: - Views
    func buildURLInputView() -> URLInputAccessoryView {
        let dismissHandler = { [weak self] in
            guard let self = self, let textView = self.textView else { return }
            textView.becomeFirstResponder()
            self.changeAccessoryView(self.accessoryView, in: textView)
        }
        let urlInputView = URLInputAccessoryView() { [weak self] enteredURL in
            self?.delegate?.didEnterURL(enteredURL)
            dismissHandler()
        }
        urlInputView.dismissHandler = dismissHandler
        return urlInputView
    }
}

// MARK: - MentionViewDelegate

extension AccessoryViewSwitcher: MentionViewDelegate {
    func selectMention(_ mention: MentionObject) {
        guard
            let mentionSymbolPosition = accessoryViewTriggerSymbolPosition,
            let previousToMentionSymbol = textView?.position(from: mentionSymbolPosition,
                                                                      offset: -1),
            let caretPosition = textView?.caretPosition() else { return }

        self.delegate?.mentionSelected(mention, from: previousToMentionSymbol, to: caretPosition)
    }

}
