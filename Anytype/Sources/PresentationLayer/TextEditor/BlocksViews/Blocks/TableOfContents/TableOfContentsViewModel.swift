import Foundation
import BlocksModels
import UIKit

struct TableOfContentsViewModel: BlockViewModelProtocol {
    
    var hashable: AnyHashable { [ info ] as [AnyHashable] }
    
    let info: BlockInformation
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        return TableOfContentsConfiguration()
            .cellBlockConfiguration(
                indentationSettings: IndentationSettings(with: info.configurationData),
                dragConfiguration: BlockDragConfiguration(id: info.id)
            )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
