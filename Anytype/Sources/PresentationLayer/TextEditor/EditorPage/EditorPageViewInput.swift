import BlocksModels


/// Input data for document view
protocol EditorPageViewInput: AnyObject {
    
    func update(header: ObjectHeader, details: ObjectDetails?)
    func update(blocks: [BlockViewModelProtocol])
    func update(syncStatus: SyncStatus)
        
    func showDeletedScreen(_ show: Bool)

    /// Tells the delegate when editing of the text block begins
    func textBlockDidBeginEditing()

    /// Tells the delegate when editing of the text block will begin
    func textBlockWillBeginEditing()
}
