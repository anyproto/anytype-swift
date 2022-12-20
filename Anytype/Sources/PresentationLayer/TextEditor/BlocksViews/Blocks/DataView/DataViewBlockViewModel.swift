import BlocksModels
import Combine
import UIKit
import AnytypeCore

struct DataViewBlockViewModel: BlockViewModelProtocol {

    let info: BlockInformation
    let objectDetails: ObjectDetails?
    
    let showFailureToast: (_ message: String) -> ()

    var hashable: AnyHashable {
        [
            info,
            objectDetails
        ] as [AnyHashable]
    }

    init(
        info: BlockInformation,
        objectDetails: ObjectDetails?,
        showFailureToast: @escaping (_ message: String) -> ())
    {
        self.info = info
        self.objectDetails = objectDetails
        self.showFailureToast = showFailureToast
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        if let objectDetails {
            return DataViewBlockConfiguration(
                content: .data(title: objectDetails.title, iconImage: objectDetails.objectIconImage)
            )
            .cellBlockConfiguration(
                indentationSettings: .init(with: info.configurationData),
                dragConfiguration: .init(id: info.id)
            )
        } else {
            return DataViewBlockConfiguration(content: .noDataSource)
                .cellBlockConfiguration(
                    indentationSettings: .init(with: info.configurationData),
                    dragConfiguration: .init(id: info.id)
                )
        }
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        if objectDetails == nil {
            showFailureToast(Loc.Content.DataView.InlineSet.Toast.failure)
        }
    }
}
