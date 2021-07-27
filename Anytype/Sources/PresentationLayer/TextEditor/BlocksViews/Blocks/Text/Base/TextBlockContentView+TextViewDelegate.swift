import UIKit

extension TextBlockContentView: TextViewDelegate {
    func sizeChanged() {
        currentConfiguration.blockDelegate.blockSizeChanged()
    }
    
    func changeFirstResponderState(_ change: TextViewFirstResponderChange) {
        switch change {
        case .become:
            currentConfiguration.blockDelegate.becomeFirstResponder(for: currentConfiguration.block)
        case .resign:
            currentConfiguration.blockDelegate.resignFirstResponder()
        }
    }
    
    func willBeginEditing() {
        currentConfiguration.blockDelegate.willBeginEditing()
    }
    
    func didBeginEditing() {
        currentConfiguration.blockDelegate.didBeginEditing()
    }
    
    func didChangeText(textView: UITextView) {
        currentConfiguration.configureMentions(textView)
    }
}
