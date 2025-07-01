import Foundation
import Services
import UIKit

struct TableOfContentsViewModel: BlockViewModelProtocol {
    
    private let contentProviderBuilder: () -> TableOfContentsContentProvider
    
    let className = "TableOfContentsViewModel"
    
    let info: BlockInformation
    let document: any BaseDocumentProtocol
    let onTap: (String) -> Void
    let editorCollectionController: EditorBlockCollectionController
    
    init(
        info: BlockInformation,
        document: some BaseDocumentProtocol,
        onTap: @escaping (String) -> Void,
        editorCollectionController: EditorBlockCollectionController
    ) {
        self.info = info
        self.document = document
        self.onTap = onTap
        self.editorCollectionController = editorCollectionController
        
        contentProviderBuilder = {
            TableOfContentsContentProvider(document: document)
        }
    }
    
    func makeContentConfiguration(maxWidth: CGFloat) -> any UIContentConfiguration {
        return TableOfContentsConfiguration(
            contentProviderBuilder: contentProviderBuilder,
            onTap: onTap,
            blockSetNeedsLayout: { editorCollectionController.reconfigure(items: [.block(self)] )}
        ).cellBlockConfiguration(
            dragConfiguration: BlockDragConfiguration(id: info.id),
            styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
