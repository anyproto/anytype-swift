import BlocksModels
import UIKit

struct DividerBlockViewModel: BlockViewModelProtocol {
    var hashable: AnyHashable { [ info ] as [AnyHashable] }
    
    let info: BlockInformation
    
    private let dividerContent: BlockDivider

    init(content: BlockDivider, info: BlockInformation) {
        self.dividerContent = content
        self.info = info
    }
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        return DividerBlockContentConfiguration(content: dividerContent).asCellBlockConfiguration
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
