import Services
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
        DividerBlockContentConfiguration(content: dividerContent)
            .cellBlockConfiguration(
                indentationSettings: .init(with: info.configurationData),
                dragConfiguration: .init(id: info.id)
            )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
