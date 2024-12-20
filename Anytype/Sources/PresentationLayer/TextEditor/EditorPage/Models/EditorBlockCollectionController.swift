import UIKit
import Services

final class EditorBlockCollectionController: EditorCollectionReloadable {
    weak var viewInput: (any EditorCollectionReloadable)?
    
    init(viewInput: (any EditorPageViewInput)?) {
        self.viewInput = viewInput
    }
    
    func reconfigure(items: [EditorItem]) {
        viewInput?.reconfigure(items: items)
    }
    
    func itemDidChangeFrame(item: EditorItem) {
        viewInput?.itemDidChangeFrame(item: item)
    }
    
    func scrollToItem(_ item: EditorItem) {
        viewInput?.scrollToItem(item)
    }
    
    func scrollToTopBlock(blockId: String) {
        viewInput?.scrollToTopBlock(blockId: blockId)
    }
    
    func scrollToTextViewIfNotVisible(textView: UITextView) {
        viewInput?.scrollToTextViewIfNotVisible(textView: textView)
    }
    
    func textBlockDidBeginEditing(firstResponderView: UIView) {
        viewInput?.textBlockDidBeginEditing(firstResponderView: firstResponderView)
    }
    
    func textBlockWillBeginEditing() {
        viewInput?.textBlockWillBeginEditing()
    }
    
    func blockDidFinishEditing() {
        viewInput?.blockDidFinishEditing()
    }
}
