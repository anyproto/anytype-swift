import Services
import Combine
import UIKit
import AnytypeCore

struct DataViewBlockViewModel: BlockViewModelProtocol {

    let info: BlockInformation
    let objectDetails: ObjectDetails?
    let isCollection: Bool
    
    private let showFailureToast: (_ message: String) -> ()
    private let openSet: (EditorScreenData) -> ()

    var hashable: AnyHashable {
        [
            info,
            objectDetails
        ] as [AnyHashable]
    }

    init(
        info: BlockInformation,
        objectDetails: ObjectDetails?,
        isCollection: Bool,
        showFailureToast: @escaping (_ message: String) -> (),
        openSet: @escaping (EditorScreenData) -> ()
    ) {
        self.info = info
        self.objectDetails = objectDetails
        self.isCollection = isCollection
        self.showFailureToast = showFailureToast
        self.openSet = openSet
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        let content: DataViewBlockContent
        let subtitle = isCollection ? Loc.Content.DataView.InlineCollection.subtitle : Loc.Content.DataView.InlineSet.subtitle
        let placeholder = isCollection ? Loc.Content.DataView.InlineCollection.untitled : Loc.Content.DataView.InlineSet.untitled
        if let objectDetails {
            let setOfIsNotEmpty = objectDetails.setOf.first { $0.isNotEmpty } != nil
            content = DataViewBlockContent(
                title: objectDetails.title,
                placeholder: placeholder,
                subtitle: subtitle,
                iconImage: objectDetails.objectIconImage,
                badgeTitle: !setOfIsNotEmpty && !isCollection ? Loc.Content.DataView.InlineSet.noData : nil
            )
        } else {
            content = DataViewBlockContent(
                title: nil,
                placeholder: placeholder,
                subtitle: subtitle,
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
        if objectDetails == nil {
            showFailureToast(Loc.Content.DataView.InlineSet.Toast.failure)
        } else if FeatureFlags.fullInlineSetImpl, let pageId = info.configurationData.parentId {
            openSet(
                EditorScreenData(
                    pageId: pageId,
                    type: .set(blockId: info.id, targetObjectID: objectDetails?.id)
                )
            )
        } else if !FeatureFlags.fullInlineSetImpl, let targetObjectID = objectDetails?.id {
            openSet(
                EditorScreenData(pageId: targetObjectID, type: .set())
            )
        }
    }
}
