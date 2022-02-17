import BlocksModels
import UIKit

struct DividerBlockViewModel: BlockViewModelProtocol {
    var hashable: AnyHashable {
        [
            indentationLevel,
            information
        ] as [AnyHashable]
    }
    
    let indentationLevel: Int
    let information: BlockInformation
    
    private let dividerContent: BlockDivider

    init(content: BlockDivider, information: BlockInformation, indentationLevel: Int) {
        self.dividerContent = content
        self.information = information
        self.indentationLevel = indentationLevel
    }
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        return DividerBlockContentConfiguration(content: dividerContent).asCellBlockConfiguration
    }
    
    func didSelectRowInTableView() {}
}
