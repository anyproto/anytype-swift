import Services
import UIKit
import AnytypeCore

struct UnsupportedBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation

    var hashable: AnyHashable { info.id }

    init(info: BlockInformation) {
        self.info = info
    }

    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        UnsupportedBlockContentConfiguration(text: Loc.unsupportedBlock)
            .cellBlockConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
            )
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) { }
}
