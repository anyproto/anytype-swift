import UIKit


protocol TextBlockAccessoryViewSwitcherDeleagte: AnyObject {
    // mention events
    func mentionSelected( _ mention: MentionObject, from: UITextPosition, to: UITextPosition)
    // editor events
    // slash events
    // done events
}


final class AccessoryViewSwitcher: AccessoryViewSwitcherProtocol {
    private enum Constants {
        static let displayActionsViewDelay: TimeInterval = 0.3
    }
    
    let textToTriggerActionsViewDisplay = "/"
    let textToTriggerMentionViewDisplay = "@"
    
    private var displayAcessoryViewTask: DispatchWorkItem?
    private(set) var accessoryViewTriggerSymbolPosition: UITextPosition?
    private weak var displayedView: (DismissableInputAccessoryView & FilterableItemsView)?
    private let mentionsView: (DismissableInputAccessoryView & FilterableItemsView)
    let editingView: EditorAccessoryView
    var slashMenuView: SlashMenuView?
    private weak var textView: UITextView?
    private weak var delegate: TextBlockAccessoryViewSwitcherDeleagte?
    
    init(textView: UITextView,
         delegate: TextBlockAccessoryViewSwitcherDeleagte,
         mentionsView: (DismissableInputAccessoryView & FilterableItemsView),
         slashMenuView: SlashMenuView? = nil,
         accessoryView: EditorAccessoryView) {
        self.textView = textView
        self.delegate = delegate
        self.slashMenuView = slashMenuView
        self.editingView = accessoryView
        self.mentionsView = mentionsView

        let dismissActionsMenu = { [weak self] in
            self?.cleanupDisplayedView()

            if let textView = self?.textView {
                self?.showEditingBars(textView: textView)
            }
        }

        self.mentionsView.dismissHandler = dismissActionsMenu
        self.slashMenuView?.dismissHandler = dismissActionsMenu
    }

    // MARK: - AccessoryViewSwitcherProtocol

    func didBeginEditing(textView: UITextView) {
        self.textView = textView

        let dismissActionsMenu = { [weak self] in
            self?.cleanupDisplayedView()

            if let textView = self?.textView {
                self?.showEditingBars(textView: textView)
            }
        }

        self.mentionsView.dismissHandler = dismissActionsMenu
        self.slashMenuView?.dismissHandler = dismissActionsMenu

        textView.inputAccessoryView = editingView
    }

    func textWillChange(textView: UITextView, replacementText: String, range: NSRange) {
        let textChangeType = textView.textChangeType(changeTextRange: range, replacementText: replacementText)
        updateDisplayedAccessoryViewState(textView: textView, textChangeType: textChangeType, replacementText: replacementText)
    }

    func textDidChange(textView: UITextView) {
        showEditingBars(textView: textView)
    }

    func selectionDidChange(textView: UITextView) {}

    func didEndEditing(textView: UITextView) {}

    // MARK: -
    
    
    func textTypingIsUsingForAccessoryViewContentFiltering() -> Bool {
        if let displayedView = displayedView, !displayedView.window.isNil {
            return true
        }
        return false
    }
    
    func cleanupDisplayedView() {
        displayedView = nil
        accessoryViewTriggerSymbolPosition = nil
    }
    
    func showEditingBars(textView: UITextView) {
        let accessoryView = variantsFromState(
            textView: textView,
            accessoryView: textView.inputAccessoryView
        )
        switchInputs(
            animated: false,
            textView: textView,
            accessoryView: accessoryView
        )
    }
    
    func showMentionsView(textView: UITextView) {
        showAccessoryView(accessoryView: mentionsView, textView: textView)
    }
    
    func showSlashMenuView(textView: UITextView) {
        showAccessoryView(accessoryView: slashMenuView, textView: textView)
    }
    
    // MARK: - Private
    
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
    
    private func variantsFromState(
        textView: UITextView,
        accessoryView: UIView?
    ) -> UIView? {
        if shouldContinueToDisplayAccessoryView(textView: textView) {
            return accessoryView
        } else {
            cleanupDisplayedView()
        }
        return self.editingView
    }
    
    // We do want to continue displaying menu view or mention view
    // if current caret position more far from begining
    // then / or @ symbol and if menu view displays any items(not empty)
    private func shouldContinueToDisplayAccessoryView(textView: UITextView) -> Bool {
        guard let accessoryView = displayedView,
              !accessoryView.window.isNil,
              let triggerSymbolPosition = accessoryViewTriggerSymbolPosition,
              let caretPosition = textView.caretPosition(),
              textView.compare(triggerSymbolPosition, to: caretPosition) != .orderedDescending,
              accessoryView.shouldContinueToDisplayView() else { return false }
        return true
    }
    
    private func updateDisplayedAccessoryViewState(textView: UITextView,
                                                   textChangeType: TextViewTextChangeType,
                                                   replacementText: String) {
        displayAcessoryViewTask?.cancel()
        // We want do to display actions menu in case
        // text was changed - "text" -> "text/"
        // but do not want to display in case
        // "text/a" -> "text/"
        guard let caretPosition = textView.caretPosition() else { return }

        if let accessoryView = displayedView,
           !accessoryView.window.isNil,
           let triggerSymbolPosition = accessoryViewTriggerSymbolPosition,
           let range = textView.textRange(from: triggerSymbolPosition, to: caretPosition) {
            accessoryView.setFilterText(filterText: textView.text(in: range) ?? "")
            return
        }
        
        guard textChangeType != .deletingSymbols else { return }

        if replacementText == textToTriggerActionsViewDisplay {
            createDelayedAcessoryViewTask(
                accessoryView: slashMenuView,
                textView: textView
            )
        } else if replacementText == textToTriggerMentionViewDisplay {
            createDelayedAcessoryViewTask(
                accessoryView: mentionsView,
                textView: textView
            )
        }
    }
    
    private func createDelayedAcessoryViewTask(accessoryView: (DismissableInputAccessoryView & FilterableItemsView)?,
                                             textView: UITextView) {
        let task = DispatchWorkItem(block: { [weak self] in
            self?.showAccessoryView(
                accessoryView: accessoryView,
                textView: textView
            )
        })
        displayAcessoryViewTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.displayActionsViewDelay, execute: task)
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
