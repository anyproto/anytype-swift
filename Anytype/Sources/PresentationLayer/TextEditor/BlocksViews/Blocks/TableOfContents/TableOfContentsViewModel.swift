import Foundation
import Services
import UIKit

struct TableOfContentsViewModel: BlockViewModelProtocol {
    
    private let contentProviderBuilder: () -> TableOfContentsContentProvider
    
    var hashable: AnyHashable { info.id }
    
    let info: BlockInformation
    let document: BaseDocumentProtocol
    let onTap: (BlockId) -> Void
    let editorCollectionController: EditorBlockCollectionController
    
    init(
        info: BlockInformation,
        document: BaseDocumentProtocol,
        onTap: @escaping (BlockId) -> Void,
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
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        return TableOfContentsConfiguration(
            contentProviderBuilder: contentProviderBuilder,
            onTap: onTap,
            blockSetNeedsLayout: { editorCollectionController.reconfigure(items: [.block(self)] )}
        ).cellBlockConfiguration(
            dragConfiguration: BlockDragConfiguration(id: info.id),
            styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
