import Services
import UIKit
import AnytypeCore

struct UnsupportedBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation

    nonisolated var hashable: AnyHashable { info.id }

    init(info: BlockInformation) {
        self.info = info
    }

    func makeContentConfiguration(maxWidth _ : CGFloat) -> any UIContentConfiguration {
        UnsupportedBlockContentConfiguration(text: Loc.unsupportedBlock)
            .cellBlockConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
            )
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) { }
}
