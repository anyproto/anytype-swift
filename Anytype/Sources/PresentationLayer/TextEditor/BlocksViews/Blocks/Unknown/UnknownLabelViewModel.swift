import BlocksModels
import UIKit
import AnytypeCore

struct UnknownLabelViewModel: BlockViewModelProtocol {    
    let indentationLevel = 0
    let information: BlockInformation
    
    var hashable: AnyHashable {
        [
            indentationLevel,
            information
        ] as [AnyHashable]
    }
    
    init(information: BlockInformation) {
        self.information = information
    }

    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        var contentConfiguration = UIListContentConfiguration.cell()
        contentConfiguration.text = "\(information.content.identifier) -> \(information.id)"
        return contentConfiguration
    }
    
    func didSelectRowInTableView() { }
}
