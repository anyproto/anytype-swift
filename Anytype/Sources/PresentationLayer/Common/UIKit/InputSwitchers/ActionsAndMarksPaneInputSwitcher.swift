
import UIKit

final class ActionsAndMarksPaneInputSwitcher: InputSwitcher {
    
    private enum Constants {
        static let displayActionsViewDelay: TimeInterval = 0.3
    }
    
    let textToTriggerActionsViewDisplay = "/"
    let textToTriggerMentionViewDisplay = "@"
    private var displayAcessoryViewTask: DispatchWorkItem?
    private(set) var accessoryViewTriggerSymbolPosition: UITextPosition?
    var textViewChange: TextViewTextChangeType?
    private weak var displayedView: (DismissableInputAccessoryView & FilterableItemsHolder)?
    
    override func switchInputs(inputViewKeyboardSize: CGSize,
                               animated: Bool,
                               textView: UITextView,
                               accessoryView: UIView?,
                               inputView: UIView?) {
        if let currentView = textView.inputView, let nextView = inputView, type(of: currentView) == type(of: nextView) {
            return
        }
        if textView.inputAccessoryView == accessoryView, textView.inputView == inputView {
            return
        }
        var shouldReloadInputViews = false
        if let inputView = inputView {
            inputView.frame = CGRect(origin: .zero, size: inputViewKeyboardSize)
            textView.inputView = inputView
            shouldReloadInputViews = true
        }
        
        if let accessoryView = accessoryView {
            textView.inputAccessoryView = accessoryView
            shouldReloadInputViews = true
        }
        if !shouldReloadInputViews {
            return
        }
        if !animated {
            textView.reloadInputViews()
        } else {
            accessoryView?.transform = CGAffineTransform(translationX: 0, y: accessoryView?.frame.size.height ?? 0)
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                accessoryView?.transform = .identity
                textView.reloadInputViews()
                textView.window?.layoutIfNeeded()
            }
        }
    }

    override func variantsFromState(customTextView: CustomTextView,
                                    selectionLength: Int,
                                    accessoryView: UIView?,
                                    inputView: UIView?) -> InputSwitcherTriplet {
        if shouldContinueToDisplayAccessoryView(customTextView: customTextView) {
            return InputSwitcherTriplet(shouldAnimate: false,
                                        accessoryView: accessoryView,
                                        inputView: nil)
        } else {
            cleanupDisplayedView()
        }
        switch (selectionLength, accessoryView, inputView) {
        // Length == 0, => set actions toolbar and restore default keyboard.
        case (0, _, _):
            return .init(shouldAnimate: false,
                         accessoryView: customTextView.editingToolbarAccessoryView,
                         inputView: nil)
        // Length != 0 and is ActionsToolbarAccessoryView => set marks pane input view and restore default accessory view (?).
        case (_, is EditingToolbarView, _):
            return .init(shouldAnimate: false,
                         accessoryView: accessoryView,
                         inputView: nil)
        // Length != 0 and is InputLink.ContainerView when textView.isFirstResponder => set highlighted accessory view and restore default keyboard.
        case (_, is CustomTextView.HighlightedToolbar.InputLink.ContainerView, _) where customTextView.textView.isFirstResponder:
            return .init(shouldAnimate: false,
                         accessoryView: customTextView.highlightedAccessoryView,
                         inputView: nil)
        // Otherwise, we need to keep accessory view and keyboard.
        default:
            return .init(shouldAnimate: false,
                         accessoryView: accessoryView,
                         inputView: inputView)
        }
    }
    
    override func switchInputs(customTextView: CustomTextView) {
        self.updateDisplayedAccessoryViewState(customTextView: customTextView)
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
    
    func showEditingBars(customTextView: CustomTextView) {
        let triplet = variantsFromState(customTextView: customTextView,
                                        selectionLength: customTextView.textView.selectedRange.length,
                                        accessoryView: customTextView.textView.inputAccessoryView,
                                        inputView: customTextView.textView.inputView)
        self.switchInputs(
            inputViewKeyboardSize: .zero,
            animated: triplet.shouldAnimate,
            textView: customTextView.textView,
            accessoryView: triplet.accessoryView,
            inputView: triplet.inputView
        )
        
        self.didSwitchViews(customTextView: customTextView)
    }
    
    func showAccessoryView(accessoryView: (DismissableInputAccessoryView & FilterableItemsHolder)?,
                           textView: UITextView) {
        switchInputs(inputViewKeyboardSize: .zero,
                     animated: true,
                     textView: textView,
                     accessoryView: accessoryView,
                     inputView: nil)
        displayedView = accessoryView
        accessoryView?.didShow(from: textView)
        accessoryViewTriggerSymbolPosition = textView.caretPosition()
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
              accessoryView.isDisplayingAnyItems() else { return false }
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
            createDelayedAcessoryViewTask(accessoryView: customTextView.menuActionsAccessoryView,
                                          textView: textView)
        } else if text.hasSuffix(textToTriggerMentionViewDisplay) {
            createDelayedAcessoryViewTask(accessoryView: customTextView.mentionView,
                                          textView: textView)
        }
    }
    
    private func createDelayedAcessoryViewTask(accessoryView: (DismissableInputAccessoryView & FilterableItemsHolder)?,
                                             textView: UITextView) {
        let task = DispatchWorkItem(block: { [weak self] in
            self?.showAccessoryView(accessoryView: accessoryView,
                                    textView: textView)
        })
        self.displayAcessoryViewTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.displayActionsViewDelay, execute: task)
    }
}
