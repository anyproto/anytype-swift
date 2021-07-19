import UIKit

final class AccessoryViewSwitcher {
    
    private enum Constants {
        static let displayActionsViewDelay: TimeInterval = 0.3
    }
    
    let textToTriggerActionsViewDisplay = "/"
    let textToTriggerMentionViewDisplay = "@"
    
    private var displayAcessoryViewTask: DispatchWorkItem?
    private(set) var accessoryViewTriggerSymbolPosition: UITextPosition?
    var textViewChange: TextViewTextChangeType?
    private weak var displayedView: (DismissableInputAccessoryView & FilterableItemsView)?
    
    func switchInputs(customTextView: CustomTextView) {
        updateDisplayedAccessoryViewState(customTextView: customTextView)
        showEditingBars(customTextView: customTextView)
    }
    
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
    
    func showAccessoryView(
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
    
    func showEditingBars(customTextView: CustomTextView) {
        let accessoryView = variantsFromState(
            customTextView: customTextView,
            accessoryView: customTextView.textView.inputAccessoryView
        )
        switchInputs(
            animated: false,
            textView: customTextView.textView,
            accessoryView: accessoryView
        )
    }
    
    // MARK: - Private
    
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
        customTextView: CustomTextView,
        accessoryView: UIView?
    ) -> UIView? {
        if shouldContinueToDisplayAccessoryView(customTextView: customTextView) {
            return accessoryView
        } else {
            cleanupDisplayedView()
        }
        return customTextView.editingToolbarAccessoryView
    }
    
    // We do want to continue displaying menu view or mention view
    // if current caret position more far from begining
    // then / or @ symbol and if menu view displays any items(not empty)
    private func shouldContinueToDisplayAccessoryView(customTextView: CustomTextView) -> Bool {
        guard let accessoryView = displayedView,
              !accessoryView.window.isNil,
              let triggerSymbolPosition = accessoryViewTriggerSymbolPosition,
              let caretPosition = customTextView.textView.caretPosition(),
              customTextView.textView.compare(triggerSymbolPosition, to: caretPosition) != .orderedDescending,
              accessoryView.shouldContinueToDisplayView() else { return false }
        return true
    }
    
    private func updateDisplayedAccessoryViewState(customTextView: CustomTextView) {
        let textView = customTextView.textView
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
        
        guard let textRange = textView.textRange(from: textView.beginningOfDocument, to: caretPosition),
              let text = textView.text(in: textRange),
        let textViewChange = textViewChange,
           textViewChange != .deletingSymbols else { return }
        
        if text.hasSuffix(textToTriggerActionsViewDisplay) {
            createDelayedAcessoryViewTask(
                accessoryView: customTextView.slashMenuView,
                textView: textView
            )
        } else if text.hasSuffix(textToTriggerMentionViewDisplay) {
            createDelayedAcessoryViewTask(accessoryView: customTextView.mentionView,
                                          textView: textView)
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
