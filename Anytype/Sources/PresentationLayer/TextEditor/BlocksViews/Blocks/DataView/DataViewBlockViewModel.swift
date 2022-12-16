import BlocksModels
import Combine
import UIKit
import AnytypeCore

struct DataViewBlockViewModel: BlockViewModelProtocol {

    let info: BlockInformation

    var hashable: AnyHashable {
        info.id as AnyHashable
    }

    init(info: BlockInformation) {
        self.info = info
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        DataViewBlockConfiguration(title: "Reading list", iconImage: nil)
            .cellBlockConfiguration(
                indentationSettings: .init(with: info.configurationData),
                dragConfiguration: .init(id: info.id)
            )
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
