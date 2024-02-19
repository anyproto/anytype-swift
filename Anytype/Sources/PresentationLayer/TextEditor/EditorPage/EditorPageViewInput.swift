import Services
import UIKit

/// Input data for document view
protocol EditorPageViewInput: RelativePositionProvider {
    
    func update(header: ObjectHeader)
    func update(details: ObjectDetails?, templatesCount: Int)
    func update(changes: CollectionDifference<EditorItem>?)
    func update(
        changes: CollectionDifference<EditorItem>?,
        allModels: [EditorItem]
    )
    func update(syncStatusData: SyncStatusData)
        
    /// Tells the delegate when editing of the text block begins
    func textBlockDidBeginEditing(firstResponderView: UIView)

    func blockDidChangeFrame()

    func textBlockDidChangeText()

    func blockDidFinishEditing(blockId: String)
    
    func scrollToBlock(blockId: String)

    func endEditing()

    func adjustContentOffset(relatively: UIView)

    func restoreEditingState()

    func didSelectTextRangeSelection(blockId: String, textView: UITextView)
}
