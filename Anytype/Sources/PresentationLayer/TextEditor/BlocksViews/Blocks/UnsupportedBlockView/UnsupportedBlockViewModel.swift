import BlocksModels
import UIKit
import AnytypeCore

struct UnsupportedBlockViewModel: BlockViewModelProtocol {
    var upperBlock: BlockModelProtocol?

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

    func makeContextualMenu() -> [ContextualMenu] {
        []
    }

    func handle(action: ContextualMenu) {
        anytypeAssertionFailure("Handling of contextual menu items not supported", domain: .unsupportedBlock)
    }

    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        let contentConfiguration = UnsupportedBlockContentConfiguration(text: "Unsupported block".localized)
        return contentConfiguration
    }

    func didSelectRowInTableView() { }
}
