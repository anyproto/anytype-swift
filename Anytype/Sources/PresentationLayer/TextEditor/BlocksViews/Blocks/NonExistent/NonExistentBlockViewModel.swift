import Services
import UIKit
import AnytypeCore

struct NonExistentBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation

    var hashable: AnyHashable { info.id }

    init(info: BlockInformation) {
        self.info = info
    }

    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        NonExistentBlockContentConfiguration(text: Loc.nonExistentObject)
            .cellBlockConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
            )
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) { }
}
