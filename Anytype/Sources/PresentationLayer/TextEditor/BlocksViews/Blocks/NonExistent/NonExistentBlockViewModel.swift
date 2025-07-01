import Services
import UIKit
import AnytypeCore

struct NonExistentBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation
    let className = "NonExistentBlockViewModel"

    init(info: BlockInformation) {
        self.info = info
    }

    func makeContentConfiguration(maxWidth _ : CGFloat) -> any UIContentConfiguration {
        NonExistentBlockContentConfiguration(text: Loc.nonExistentObject)
            .cellBlockConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
            )
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) { }
}
