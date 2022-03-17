import BlocksModels
import UIKit
import AnytypeCore

struct UnknownLabelViewModel: BlockViewModelProtocol {    
    let indentationLevel = 0
    let info: BlockInformation
    
    var hashable: AnyHashable {
        [
            indentationLevel,
            info
        ] as [AnyHashable]
    }

    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        var contentConfiguration = UIListContentConfiguration.cell()
        contentConfiguration.text = "\(info.content.identifier) -> \(info.id)"
        return contentConfiguration
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
