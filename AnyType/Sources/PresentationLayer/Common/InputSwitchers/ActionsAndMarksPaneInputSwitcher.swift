
import UIKit

final class ActionsAndMarksPaneInputSwitcher: InputSwitcher {
    
    private enum Constants {
        static let textToTriggerActionsViewDisplay = " /"
        static let displayActionsViewDelay: TimeInterval = 0.3
        static let minimumActionsViewHeight: CGFloat = 215
    }
    
    private var displayActionsViewTask: DispatchWorkItem?
    private let menuItemsBuilder: BlockActionsBuilder
    
    init(menuItemsBuilder: BlockActionsBuilder) {
        self.menuItemsBuilder = menuItemsBuilder
    }
    
    override func switchInputs(_ inputViewKeyboardSize: CGSize,
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
            accessoryView.transform = CGAffineTransform(translationX: 0, y: accessoryView.frame.size.height)
            shouldReloadInputViews = true
        }
        if shouldReloadInputViews {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                accessoryView?.transform = .identity
                textView.reloadInputViews()
                textView.window?.layoutIfNeeded()
            }
        }
    }

    override func variantsFromState(_ coordinator: Coordinator,
                                    textView: UITextView,
                                    selectionLength: Int,
                                    accessoryView: UIView?, inputView: UIView?) -> InputSwitcherTriplet? {
        self.updateActionsViewDisplayState(textView: textView)
        switch (selectionLength, accessoryView, inputView) {
        // Length == 0, => set actions toolbar and restore default keyboard.
        case (0, _, _): return .init(shouldAnimate: true, accessoryView: coordinator.editingToolbarAccessoryView, inputView: nil)
        // Length != 0 and is ActionsToolbarAccessoryView => set marks pane input view and restore default accessory view (?).
        case (_, is EditingToolbarView, _): return .init(shouldAnimate: true, accessoryView: nil, inputView: coordinator.marksToolbarInputView.view)
        // Length != 0 and is InputLink.ContainerView when textView.isFirstResponder => set highlighted accessory view and restore default keyboard.
        case (_, is TextView.HighlightedToolbar.InputLink.ContainerView, _) where textView.isFirstResponder: return .init(shouldAnimate: true, accessoryView: coordinator.highlightedAccessoryView, inputView: nil)
        // Otherwise, we need to keep accessory view and keyboard.
        default: return .init(shouldAnimate: false, accessoryView: accessoryView, inputView: inputView)
        }
    }
    
    override func didSwitchViews(_ coordinator: Coordinator,
                                 textView: UITextView) {
        if (textView.inputView == coordinator.marksToolbarInputView.view) {
            let range = textView.selectedRange
            let attributedText = textView.textStorage
            coordinator.updateMarksInputView((range, attributedText, textView))
        }
    }
    
    override func switchInputs(_ coordinator: Coordinator,
                               textView: UITextView) {
        guard let triplet = self.variantsFromState(coordinator,
                                                   textView: textView,
                                                   selectionLength: textView.selectedRange.length,
                                                   accessoryView: textView.inputAccessoryView,
                                                   inputView: textView.inputView) else { return }
        
        let (_, accessoryView, inputView) = (triplet.shouldAnimate, triplet.accessoryView, triplet.inputView)
        
        self.switchInputs(coordinator.defaultKeyboardRect.size,
                          textView: textView,
                          accessoryView: accessoryView,
                          inputView: inputView)
        
        self.didSwitchViews(coordinator, textView: textView)
    }
    
    private func updateActionsViewDisplayState(textView: UITextView) {
        self.displayActionsViewTask?.cancel()
        let selectedRange = textView.selectedRange
        let offset = selectedRange.location + selectedRange.length
        if let caretPosition = textView.position(from: textView.beginningOfDocument, offset: offset),
           let textRange = textView.textRange(from: textView.beginningOfDocument, to: caretPosition),
           let text = textView.text(in: textRange),
           text.hasSuffix(Constants.textToTriggerActionsViewDisplay) {
            self.createDelayedActonsViewTask(textView: textView)
        }
    }
    
    private func createDelayedActonsViewTask(textView: UITextView) {
        let task = DispatchWorkItem(block: { [weak self] in
            let view = BlockActionsView(parentTextView: textView,
                                        frame: CGRect(origin: .zero,
                                                      size: CGSize(width: UIScreen.main.bounds.width,
                                                                   height: Constants.minimumActionsViewHeight)))
            self?.switchInputs(.zero, textView: textView, accessoryView: view, inputView: nil)
        })
        self.displayActionsViewTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.displayActionsViewDelay, execute: task)
    }
}
