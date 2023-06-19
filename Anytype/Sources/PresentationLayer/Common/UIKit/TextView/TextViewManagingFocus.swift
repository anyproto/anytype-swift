import Services

protocol TextViewManagingFocus: AnyObject {
    func shouldResignFirstResponder()
    func setFocus(_ position: BlockFocusPosition)
    func obtainFocusPosition() -> BlockFocusPosition?
}

extension CustomTextView: TextViewManagingFocus {
    func shouldResignFirstResponder() {
        _ = textView.resignFirstResponder()
    }

    func setFocus(_ position: BlockFocusPosition) {
        textView.setFocus(position)
    }

    func obtainFocusPosition() -> BlockFocusPosition? {
        guard textView.isFirstResponder else { return nil }
        
        let caretLocation = textView.selectedRange.location
        if caretLocation == 0 {
            return .beginning
        }
        return .at(textView.selectedRange)
    }
}
