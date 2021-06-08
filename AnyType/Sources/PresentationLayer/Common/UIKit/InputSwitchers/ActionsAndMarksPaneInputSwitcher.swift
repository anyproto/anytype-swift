
import UIKit

final class ActionsAndMarksPaneInputSwitcher: InputSwitcher {
    
    private enum Constants {
        static let displayActionsViewDelay: TimeInterval = 0.3
    }
    
    let textToTriggerActionsViewDisplay = "/"
    private var displayActionsViewTask: DispatchWorkItem?
    private var actionsViewTriggerSymbolPosition: UITextPosition?
    var textViewChange: TextViewTextChangeType?
    
    override func switchInputs(_ inputViewKeyboardSize: CGSize,
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

    override func variantsFromState(_ coordinator: BlockTextViewCoordinator,
                                    textView: UITextView,
                                    selectionLength: Int,
                                    accessoryView: UIView?,
                                    inputView: UIView?) -> InputSwitcherTriplet? {
        if shouldContinueToDisplayActionsMenu(coordinator: coordinator, textView: textView) {
            return InputSwitcherTriplet(shouldAnimate: false,
                                        accessoryView: coordinator.menuActionsAccessoryView,
                                        inputView: nil)
        }
        switch (selectionLength, accessoryView, inputView) {
        // Length == 0, => set actions toolbar and restore default keyboard.
        case (0, _, _):
            return .init(shouldAnimate: false,
                         accessoryView: coordinator.editingToolbarAccessoryView,
                         inputView: nil)
        // Length != 0 and is ActionsToolbarAccessoryView => set marks pane input view and restore default accessory view (?).
        case (_, is EditingToolbarView, _):
            return .init(shouldAnimate: false,
                         accessoryView: accessoryView,
                         inputView: nil)
        // Length != 0 and is InputLink.ContainerView when textView.isFirstResponder => set highlighted accessory view and restore default keyboard.
        case (_, is BlockTextView.HighlightedToolbar.InputLink.ContainerView, _) where textView.isFirstResponder:
            return .init(shouldAnimate: false,
                         accessoryView: coordinator.highlightedAccessoryView,
                         inputView: nil)
        // Otherwise, we need to keep accessory view and keyboard.
        default:
            return .init(shouldAnimate: false,
                         accessoryView: accessoryView,
                         inputView: inputView)
        }
    }
    
    override func didSwitchViews(_ coordinator: BlockTextViewCoordinator,
                                 textView: UITextView) {
        if (textView.inputView == coordinator.marksToolbarInputView.view) {
            let range = textView.selectedRange
            let attributedText = textView.textStorage
            coordinator.updateMarksInputView((range, attributedText, textView))
        }
    }
    
    override func switchInputs(_ coordinator: BlockTextViewCoordinator,
                               textView: UITextView) {
        self.updateActionsViewDisplayState(coordinator: coordinator, textView: textView)
        showEditingBars(coordinator: coordinator, textView: textView)
    }
    
    func showEditingBars(coordinator: BlockTextViewCoordinator,
                              textView: UITextView) {
        guard let triplet = self.variantsFromState(coordinator,
                                                   textView: textView,
                                                   selectionLength: textView.selectedRange.length,
                                                   accessoryView: textView.inputAccessoryView,
                                                   inputView: textView.inputView) else { return }
        self.switchInputs(coordinator.defaultKeyboardRect.size,
                          animated: triplet.shouldAnimate,
                          textView: textView,
                          accessoryView: triplet.accessoryView,
                          inputView: triplet.inputView)
        
        self.didSwitchViews(coordinator, textView: textView)
    }
    
    func showMenuActionsView(coordinator: BlockTextViewCoordinator,
                             textView: UITextView) {
        switchInputs(.zero,
                     animated: true,
                     textView: textView,
                     accessoryView: coordinator.menuActionsAccessoryView,
                     inputView: nil)
        coordinator.menuActionsAccessoryView?.didShow(from: textView)
        actionsViewTriggerSymbolPosition = textView.caretPosition()
    }
    
    // We do want to continue displaying menu view
    // if current caret position more far from begining
    // then / symbol and if menu view displays any items(not empty)
    private func shouldContinueToDisplayActionsMenu(coordinator: BlockTextViewCoordinator,
                                                    textView: UITextView) -> Bool {
        guard let menuView = coordinator.menuActionsAccessoryView,
              !menuView.window.isNil,
              let triggerSymbolPosition = actionsViewTriggerSymbolPosition,
              let caretPosition = textView.caretPosition(),
              textView.compare(triggerSymbolPosition, to: caretPosition) != .orderedDescending,
              menuView.isDisplayingAnyItems() else { return false }
        return true
    }
    
    private func updateActionsViewDisplayState(coordinator: BlockTextViewCoordinator, textView: UITextView) {
        self.displayActionsViewTask?.cancel()
        // We want do to display actions menu in case
        // text was changed - "text" -> "text/"
        // but do not want to display in case
        // "text/a" -> "text/"
        guard let caretPosition = textView.caretPosition() else { return }
        if coordinator.menuActionsAccessoryView?.window != nil,
           let triggerSymbolPosition = actionsViewTriggerSymbolPosition,
           let range = textView.textRange(from: triggerSymbolPosition, to: caretPosition) {
            coordinator.menuActionsAccessoryView?.setFilterText(filterText: textView.text(in: range) ?? "")
            return
        }
        if let textViewChange = textViewChange,
           textViewChange != .deletingSymbols,
           let textRange = textView.textRange(from: textView.beginningOfDocument, to: caretPosition),
           let text = textView.text(in: textRange),
           text.hasSuffix(textToTriggerActionsViewDisplay) {
            self.createDelayedActonsViewTask(coordinator: coordinator,
                                             textView: textView)
        }
    }
    
    private func createDelayedActonsViewTask(coordinator: BlockTextViewCoordinator,
                                             textView: UITextView) {
        let task = DispatchWorkItem(block: { [weak self] in
            self?.showMenuActionsView(coordinator: coordinator, textView: textView)
        })
        self.displayActionsViewTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.displayActionsViewDelay, execute: task)
    }
}
