import Foundation
import BlocksModels
import UIKit

struct TableOfContentsViewModel: BlockViewModelProtocol {
    
    private let contentProviderBuilder: () -> TableOfContentsContentProvider
    
    var hashable: AnyHashable { [ info ] as [AnyHashable] }
    
    let info: BlockInformation
    let document: BaseDocumentProtocol
    let onTap: (BlockId) -> Void
    let blockSetNeedsLayout: () -> Void
    
    init(
        info: BlockInformation,
        document: BaseDocumentProtocol,
        onTap: @escaping (BlockId) -> Void,
        blockSetNeedsLayout: @escaping () -> Void
    ) {
        self.info = info
        self.document = document
        self.onTap = onTap
        self.blockSetNeedsLayout = blockSetNeedsLayout
        contentProviderBuilder = {
            TableOfContentsContentProvider(document: document)
        }
    }
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        return TableOfContentsConfiguration(
            contentProviderBuilder: contentProviderBuilder,
            onTap: onTap,
            blockSetNeedsLayout: blockSetNeedsLayout
        ).cellBlockConfiguration(
            indentationSettings: IndentationSettings(with: info.configurationData),
            dragConfiguration: BlockDragConfiguration(id: info.id)
        )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
