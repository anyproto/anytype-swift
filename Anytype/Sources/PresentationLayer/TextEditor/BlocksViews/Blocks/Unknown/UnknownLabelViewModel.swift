import BlocksModels
import UIKit

struct UnknownLabelViewModel: BlockViewModelProtocol {
    let indentationLevel = 0
    let information: BlockInformation
    
    var diffable: AnyHashable {
        information.id
    }
    
    init(information: BlockInformation) {
        self.information = information
    }
    
    func makeContextualMenu() -> ContextualMenu {
        ContextualMenu(title: "")
    }
    
    func handle(action: ContextualMenuAction) { }
    
    func makeContentConfiguration() -> UIContentConfiguration {
        var contentConfiguration = UIListContentConfiguration.cell()
        contentConfiguration.text = "\(information.content.identifier) -> \(information.id)"
        return contentConfiguration
    }
    
    func didSelectRowInTableView() { }
}
