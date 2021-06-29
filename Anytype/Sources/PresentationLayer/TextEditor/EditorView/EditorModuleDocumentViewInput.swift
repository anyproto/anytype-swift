import BlocksModels


/// Input data for document view
protocol EditorModuleDocumentViewInput: AnyObject {
    /// Update data with new rows
    ///
    /// - Parameters:
    ///   - rows: Rows to display
    func updateData(_ rows: [BlockViewModelProtocol])

    func updateHeader()

    func selectBlock(blockId: BlockId)

    /// Ask view rebuild layout
    func needsUpdateLayout()

    /// Tells the delegate when editing of the text block begins
    func textBlockDidBeginEditing()

    /// Tells the delegate when editing of the text block will begin
    func textBlockWillBeginEditing()
}
