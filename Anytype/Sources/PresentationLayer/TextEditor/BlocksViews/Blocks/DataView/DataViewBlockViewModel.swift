import BlocksModels
import Combine
import UIKit
import AnytypeCore

struct DataViewBlockViewModel: BlockViewModelProtocol {

    let info: BlockInformation
    let objectDetails: ObjectDetails?

    var hashable: AnyHashable {
        info.id as AnyHashable
    }

    init(info: BlockInformation, objectDetails: ObjectDetails?) {
        self.info = info
        self.objectDetails = objectDetails
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        if let objectDetails {
            return DataViewBlockConfiguration(title: objectDetails.title, iconImage: objectDetails.objectIconImage)
                .cellBlockConfiguration(
                    indentationSettings: .init(with: info.configurationData),
                    dragConfiguration: .init(id: info.id)
                )
        } else {
            return DataViewBlockConfiguration(title: "No data source", iconImage: nil)
                .cellBlockConfiguration(
                    indentationSettings: .init(with: info.configurationData),
                    dragConfiguration: .init(id: info.id)
                )
        }
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
