import UIKit
import Services

final class EditorBlockCollectionController: EditorCollectionReloadable {
    weak var viewInput: EditorCollectionReloadable?
    
    init(viewInput: EditorPageViewInput?) {
        self.viewInput = viewInput
    }
    
    func reload(items: [EditorItem]) {
        viewInput?.reload(items: items)
    }
    
    func reconfigure(items: [EditorItem]) {
        viewInput?.reconfigure(items: items)
    }
    
    func itemDidChangeFrame(item: EditorItem) {
        viewInput?.itemDidChangeFrame(item: item)
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
    
    func didSelectTextRangeSelection(blockId: String, textView: UITextView) {
        viewInput?.didSelectTextRangeSelection(blockId: blockId, textView: textView)
    }
}
