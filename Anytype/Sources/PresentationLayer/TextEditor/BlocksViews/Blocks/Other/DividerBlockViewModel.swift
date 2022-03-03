import BlocksModels
import UIKit

struct DividerBlockViewModel: BlockViewModelProtocol {
    var hashable: AnyHashable { [ information ] as [AnyHashable] }
    
    let information: BlockInformation
    
    private let dividerContent: BlockDivider

    init(content: BlockDivider, information: BlockInformation) {
        self.dividerContent = content
        self.information = information
    }
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        return DividerBlockContentConfiguration(content: dividerContent).asCellBlockConfiguration
    }
    
    func didSelectRowInTableView() {}
}
