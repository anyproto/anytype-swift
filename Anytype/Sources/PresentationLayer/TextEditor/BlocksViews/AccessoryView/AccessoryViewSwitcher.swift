import UIKit
import BlocksModels


protocol AccessoryViewSwitcherDelegate: AnyObject {
    // mention events
    func mentionSelected( _ mention: MentionObject, from: UITextPosition, to: UITextPosition)
    
    /// Delegate method called after url was entered from accessory view
    func didEnterURL(_ url: URL?)
}

protocol AccessoryViewSwitcherProtocol: AnyObject {
    var textToTriggerSlashViewDisplay: String { get }
    var textToTriggerMentionViewDisplay: String { get }
    
    func showSlashMenuView(textView: UITextView)
    func showMentionsView(textView: UITextView)
    
    func updateBlockType(with type: BlockContentType)
    func showURLInput(textView: UITextView, url: URL?)
    
    func didBeginEditing(textView: UITextView)
    func textDidChange(textView: UITextView)
    func textWillChange(textView: UITextView, replacementText: String, range: NSRange)
}

final class AccessoryViewSwitcher: AccessoryViewSwitcherProtocol {
    let textToTriggerSlashViewDisplay = "/"
    let textToTriggerMentionViewDisplay = "@"
    
    private var displayAcessoryViewTask: DispatchWorkItem?
    private(set) var accessoryViewTriggerSymbolPosition: UITextPosition?
    
    private weak var displayedView: (DismissableInputAccessoryView & FilterableItemsView)?
    
    private let mentionsView: MentionView
    private let accessoryView: EditorAccessoryView
    private var slashMenuView: SlashMenuView
    private weak var textView: UITextView?
    private weak var delegate: AccessoryViewSwitcherDelegate?
    private var latestTextViewTextChange: TextViewTextChangeType?
    
    init(
        textView: UITextView,
        delegate: AccessoryViewSwitcherDelegate,
        mentionsView: MentionView,
        slashMenuView: SlashMenuView,
        accessoryView: EditorAccessoryView
    ) {
        self.textView = textView
        self.delegate = delegate
        self.slashMenuView = slashMenuView
        self.accessoryView = accessoryView
        self.mentionsView = mentionsView
    }

    // MARK: - Public methods

    func didBeginEditing(textView: UITextView) {
        self.textView = textView

        let dismissActionsMenu = { [weak self] in
            self?.cleanupDisplayedView()

            if let textView = self?.textView {
                self?.showEditingBars(textView: textView)
            }
        }

        mentionsView.dismissHandler = dismissActionsMenu
        slashMenuView.dismissHandler = dismissActionsMenu

        textView.inputAccessoryView = accessoryView
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

    func updateBlockType(with type: BlockContentType) {
        if type == .text(.title) {
            accessoryView.updateMenuItems([.style])
        } else {
            accessoryView.updateMenuItems([.slash, .style, .mention])
        }

        let restrictions = BlockRestrictionsFactory().makeRestrictions(for: type)
        slashMenuView.menuItems = BlockActionsBuilder(
            restrictions: restrictions
        ).makeBlockActionsMenuItems()
    }
    
    func showMentionsView(textView: UITextView) {
        showAccessoryView(accessoryView: mentionsView, textView: textView)
    }
    
    func showSlashMenuView(textView: UITextView) {
        showAccessoryView(accessoryView: slashMenuView, textView: textView)
    }
    
    func showURLInput(textView: UITextView, url: URL?) {
        let dismissHandler = { [weak self] in
            guard let self = self, let textView = self.textView else { return }
            textView.becomeFirstResponder()
            self.showEditingBars(textView: textView)
        }
        let urlInputView = URLInputAccessoryView(url: url) { [weak self] enteredURL in
            self?.delegate?.didEnterURL(enteredURL)
            dismissHandler()
        }
        urlInputView.dismissHandler = dismissHandler
        switchInputs(
            animated: false,
            textView: textView,
            accessoryView: urlInputView
        )
        urlInputView.urlInputView.textField.becomeFirstResponder()
        cleanupDisplayedView()
    }
    
    // MARK: - Private methods
    
    private func showEditingBars(textView: UITextView) {
        switchInputs(
            animated: false,
            textView: textView,
            accessoryView: accessoryView
        )
    }
    
    private func cleanupDisplayedView() {
        displayedView = nil
        accessoryViewTriggerSymbolPosition = nil
    }
    
    private func showAccessoryView(
        accessoryView: (DismissableInputAccessoryView & FilterableItemsView)?,
        textView: UITextView
    ) {
        switchInputs(
            animated: true,
            textView: textView,
            accessoryView: accessoryView
        )
        displayedView = accessoryView
        accessoryView?.didShow(from: textView)
        accessoryViewTriggerSymbolPosition = textView.caretPosition()
    }
    
    private func switchInputs(
        animated: Bool,
        textView: UITextView,
        accessoryView: UIView?
    ) {
        guard textView.inputAccessoryView != accessoryView,
              let accessoryView = accessoryView else {
            return
        }
        textView.inputAccessoryView = accessoryView
        if !animated {
            textView.reloadInputViews()
        } else {
            accessoryView.transform = CGAffineTransform(translationX: 0, y: accessoryView.frame.size.height)
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                accessoryView.transform = .identity
                textView.reloadInputViews()
                textView.window?.layoutIfNeeded()
            }
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
            showEditingBars(textView: textView)
            return
        }
        guard let triggerSymbolPosition = accessoryViewTriggerSymbolPosition,
              let caretPosition = textView.caretPosition(),
              textView.compare(triggerSymbolPosition, to: caretPosition) == .orderedDescending else {
            return
        }
        cleanupDisplayedView()
        showEditingBars(textView: textView)
    }
    
    private func setFilterTextToView(in textView: UITextView) {
        guard let filterText = filterText(from: textView) else { return }
        displayedView?.setFilterText(filterText: filterText)
        dismissDisplayedViewIfNeeded(textView: textView)
    }
    
    private func displayFilterableViewIfNeeded(textView: UITextView) {
        guard let textBeforeCaret = textView.textBeforeCaret() else { return }
        if textBeforeCaret.hasSuffix(textToTriggerSlashViewDisplay) {
            createDelayedAcessoryViewTask(
                accessoryView: slashMenuView,
                textView: textView
            )
        } else if textBeforeCaret.hasSuffix(textToTriggerMentionViewDisplay) {
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
