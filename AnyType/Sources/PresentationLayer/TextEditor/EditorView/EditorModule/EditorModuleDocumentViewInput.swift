import BlocksModels


/// Input data for document view
protocol EditorModuleDocumentViewInput: AnyObject {
    
    /// Set focus
    ///
    /// - Parameter index: Block index
    func setFocus(at index: Int)
 
    /// Update data with new rows
    ///
    /// - Parameters:
    ///   - rows: Rows to display
    func updateData(_ rows: [BaseBlockViewModel])

    /// Show code language view selection.
    /// 
    /// - Parameters:
    ///   - languages: List of code languages
    ///   - completion: Return selected language as String type
    func showCodeLanguageView(with languages: [String], completion: @escaping (_ language: String) -> Void)

    /// Show style menu
    func showStyleMenu(blockModel: BlockModelProtocol)
}
