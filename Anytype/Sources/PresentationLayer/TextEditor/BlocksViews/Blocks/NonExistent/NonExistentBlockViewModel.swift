import BlocksModels
import UIKit
import AnytypeCore

struct NonExistentBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation

    var hashable: AnyHashable {
        [
            info
        ] as [AnyHashable]
    }

    init(info: BlockInformation) {
        self.info = info
    }

    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        NonExistentBlockContentConfiguration(text: Loc.nonExistentObject)
            .cellBlockConfiguration(
                indentationSettings: .init(with: info.configurationData),
                dragConfiguration: .init(id: info.id)
            )
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) { }
}
