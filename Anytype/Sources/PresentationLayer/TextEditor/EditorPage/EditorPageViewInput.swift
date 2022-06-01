import BlocksModels
import UIKit


/// Input data for document view
protocol EditorPageViewInput: AnyObject, RelativePositionProvider {
    
    func update(header: ObjectHeader, details: ObjectDetails?)
    func update(
        changes: CollectionDifference<EditorItem>?,
        allModels: [EditorItem]
    )
    func update(syncStatus: SyncStatus)
        
    func showDeletedScreen(_ show: Bool)

    /// Tells the delegate when editing of the text block begins
    func textBlockDidBeginEditing(firstResponderView: UIView)

    func blockDidChangeFrame()

    func textBlockDidChangeText()

    /// Tells the delegate when editing of the text block will begin
    func textBlockWillBeginEditing()

    func blockDidFinishEditing(blockId: BlockId)
}
