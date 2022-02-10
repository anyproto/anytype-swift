import BlocksModels
import UIKit
import AnytypeCore

struct UnsupportedBlockViewModel: BlockViewModelProtocol {
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
        let contentConfiguration = UnsupportedBlockContentConfiguration(text: "Unsupported block".localized)
        return contentConfiguration
    }

    func didSelectRowInTableView() { }
}
