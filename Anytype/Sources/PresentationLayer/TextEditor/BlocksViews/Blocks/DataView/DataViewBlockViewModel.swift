import BlocksModels
import Combine
import UIKit
import AnytypeCore

struct DataViewBlockViewModel: BlockViewModelProtocol {

    let info: BlockInformation
    let objectDetails: ObjectDetails?
    
    private let showFailureToast: (_ message: String) -> ()
    private let openInlineSet: (EditorScreenData) -> ()

    var hashable: AnyHashable {
        [
            info,
            objectDetails
        ] as [AnyHashable]
    }

    init(
        info: BlockInformation,
        objectDetails: ObjectDetails?,
        showFailureToast: @escaping (_ message: String) -> (),
        openInlineSet: @escaping (EditorScreenData) -> ()
    ) {
        self.info = info
        self.objectDetails = objectDetails
        self.showFailureToast = showFailureToast
        self.openInlineSet = openInlineSet
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        let content: DataViewBlockContent
        if let objectDetails {
            content = DataViewBlockContent(
                title: objectDetails.title,
                iconImage: objectDetails.objectIconImage,
                badgeTitle: objectDetails.setOf.isEmpty ? Loc.Content.DataView.InlineSet.noData : nil
            )
        } else {
            content = DataViewBlockContent(
                title: nil,
                iconImage: nil,
                badgeTitle: Loc.Content.DataView.InlineSet.noSource
            )
        }
        return DataViewBlockConfiguration(
            content: content
        )
        .cellBlockConfiguration(
            indentationSettings: .init(with: info.configurationData),
            dragConfiguration: .init(id: info.id)
        )
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        if let pageId = info.configurationData.parentId {
            openInlineSet(
                EditorScreenData(
                    pageId: pageId,
                    type: .set(blockId: info.id, targetObjectID: objectDetails?.id)
                )
            )
        } else if objectDetails == nil {
            showFailureToast(Loc.Content.DataView.InlineSet.Toast.failure)
        }
    }
}
