
import UIKit

final class BlocksAndHighlightingInputSwitcher: InputSwitcher {
    
    override func variantsFromState(_ coordinator: BlockTextViewCoordinator,
                                    textView: UITextView,
                                    selectionLength: Int,
                                    accessoryView: UIView?,
                                    inputView: UIView?) -> InputSwitcherTriplet? {
        switch (selectionLength, accessoryView, inputView) {
        // Length == 0, => set blocks toolbar and restore default keyboard.
        case (0, _, _): return .init(shouldAnimate: true, accessoryView: coordinator.blocksAccessoryView, inputView: nil)
        // Length != 0 and is BlockToolbarAccessoryView => set highlighted accessory view and restore default keyboard.
        case (_, is BlockTextViewCoordinator.BlockToolbarAccesoryView, _): return .init(shouldAnimate: true, accessoryView: coordinator.highlightedAccessoryView, inputView: nil)
        // Length != 0 and is InputLink.ContainerView when textView.isFirstResponder => set highlighted accessory view and restore default keyboard.
        case (_, is BlockTextView.HighlightedToolbar.InputLink.ContainerView, _) where textView.isFirstResponder: return .init(shouldAnimate: true, accessoryView: coordinator.highlightedAccessoryView, inputView: nil)
        // Otherwise, we need to keep accessory view and keyboard.
        default: return .init(shouldAnimate: false, accessoryView: accessoryView, inputView: inputView)
        }
    }
    
    override func didSwitchViews(_ coordinator: BlockTextViewCoordinator,
                                 textView: UITextView) {
        if (textView.inputAccessoryView is BlockTextViewCoordinator.HighlightedAccessoryView) {
            let range = textView.selectedRange
            let attributedText = textView.textStorage
            coordinator.updateHighlightedAccessoryView((range, attributedText))
        }
    }
}
