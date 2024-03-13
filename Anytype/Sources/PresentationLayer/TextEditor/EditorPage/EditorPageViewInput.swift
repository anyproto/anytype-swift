import Services
import UIKit

protocol EditorCollectionReloadable: AnyObject {
    func reload(items: [EditorItem])
    func reconfigure(items: [EditorItem])
    func itemDidChangeFrame(item: EditorItem)
    func scrollToTopBlock(blockId: String) // Change to editorItem
    
    func scrollToTextViewIfNotVisible(textView: UITextView)
    
    /// Tells the delegate when editing of the text block begins
    func textBlockDidBeginEditing(firstResponderView: UIView)
    func textBlockWillBeginEditing()
    func blockDidFinishEditing()
    func didSelectTextRangeSelection(blockId: String, textView: UITextView)
}

/// Input data for document view
protocol EditorPageViewInput: EditorCollectionReloadable {
    func update(header: ObjectHeader)
    func update(details: ObjectDetails?, permissions: ObjectPermissions, templatesCount: Int)
    func update(
        changes: CollectionDifference<EditorItem>?,
        allModels: [EditorItem],
        completion: @escaping () -> Void
    )
    func update(syncStatus: SyncStatus)
    
    func endEditing()

    func adjustContentOffset(relatively: UIView)

    func restoreEditingState()
}
