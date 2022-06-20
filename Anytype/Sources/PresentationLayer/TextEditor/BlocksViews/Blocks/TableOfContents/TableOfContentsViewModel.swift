import Foundation
import BlocksModels
import UIKit

struct TableOfContentsViewModel: BlockViewModelProtocol {
    
    private let contentProviderBuilder: () -> TableOfContentsContentProvider
    
    var hashable: AnyHashable { [ info ] as [AnyHashable] }
    
    let info: BlockInformation
    let document: BaseDocumentProtocol
    let blockSetNeedsLayout: () -> Void
    
    init(info: BlockInformation, document: BaseDocumentProtocol, blockSetNeedsLayout: @escaping () -> Void) {
        self.info = info
        self.document = document
        self.blockSetNeedsLayout = blockSetNeedsLayout
        contentProviderBuilder = {
            TableOfContentsContentProvider(document: document)
        }
    }
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        return TableOfContentsConfiguration(
            blockId: info.id,
            contentProviderBuilder: contentProviderBuilder,
            blockSetNeedsLayout: blockSetNeedsLayout
        ).cellBlockConfiguration(
            indentationSettings: IndentationSettings(with: info.configurationData),
            dragConfiguration: BlockDragConfiguration(id: info.id)
        )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
