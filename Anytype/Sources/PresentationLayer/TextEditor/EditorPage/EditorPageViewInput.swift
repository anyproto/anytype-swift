import Services
import UIKit

/// Input data for document view
protocol EditorPageViewInput: RelativePositionProvider {
    
    func update(header: ObjectHeader, details: ObjectDetails?)
    func update(changes: CollectionDifference<EditorItem>?)
    func update(
        changes: CollectionDifference<EditorItem>?,
        allModels: [EditorItem]
    )
    func update(syncStatus: SyncStatus)
        
    /// Tells the delegate when editing of the text block begins
    func textBlockDidBeginEditing(firstResponderView: UIView)

    func blockDidChangeFrame()

    func textBlockDidChangeText()

    /// Tells the delegate when editing of the text block will begin
    func textBlockWillBeginEditing()

    func blockDidFinishEditing(blockId: BlockId)
    
    func scrollToBlock(blockId: BlockId)

    func endEditing()

    func adjustContentOffset(relatively: UIView)

    func restoreEditingState()

    func didSelectTextRangeSelection(blockId: BlockId, textView: UITextView)
}
