import Services
import Combine
import UIKit
import AnytypeCore

final class DataViewBlockViewModel: BlockViewModelProtocol {

    let blockInformationProvider: BlockModelInfomationProvider
    let document: BaseDocumentProtocol
    
    private let showFailureToast: (_ message: String) -> ()
    private let openSet: (EditorScreenData) -> ()
    private weak var reloadable: EditorCollectionReloadable?
    private var targetDetails: ObjectDetails?
    
    var info: BlockInformation { blockInformationProvider.info }

    var hashable: AnyHashable { info.id }
    var detailsSubscription: AnyCancellable?

    private var blockData: BlockDataview {
        guard case let .dataView(data) = info.content else {
            anytypeAssertionFailure("DataViewBlockViewModel's blockInformation has wrong content type")
            return .empty
        }
        
        return data
    }
    
    init(
        blockInformationProvider: BlockModelInfomationProvider,
        document: BaseDocumentProtocol,
        reloadable: EditorCollectionReloadable?,
        showFailureToast: @escaping (_ message: String) -> (),
        openSet: @escaping (EditorScreenData) -> ()
    ) {
        self.blockInformationProvider = blockInformationProvider
        self.document = document
        self.reloadable = reloadable
        self.showFailureToast = showFailureToast
        self.openSet = openSet
        
        detailsSubscription = document
            .subscribeForDetails(objectId: blockData.targetObjectID)
            .sinkOnMain { [weak self] _ in
                guard let self = self else { return }
                self.targetDetails = targetDetails
                let selfItem = EditorItem.block(self)
                self.reloadable?.reconfigure(items: [selfItem])
            }
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        guard case let .dataView(data) = info.content, 
                !(targetDetails?.isDeleted ?? false) else {
            return NonExistentBlockViewModel(info: info)
                .makeContentConfiguration(maxWidth: maxWidth)
        }
        
        let isCollection = data.isCollection
        
        let content: DataViewBlockContent
        let subtitle = isCollection ? Loc.Content.DataView.InlineCollection.subtitle : Loc.Content.DataView.InlineSet.subtitle
        let placeholder = isCollection ? Loc.Content.DataView.InlineCollection.untitled : Loc.Content.DataView.InlineSet.untitled
        if let objectDetails = targetDetails {
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
            dragConfiguration: .init(id: info.id),
            styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        guard let objectDetails = targetDetails else {
            showFailureToast(Loc.Content.DataView.InlineSet.Toast.failure)
            return
        }
        
        if FeatureFlags.fullInlineSetImpl, let pageId = info.configurationData.parentId {
            openSet(
                .set(
                    EditorSetObject(
                        objectId: pageId,
                        spaceId: objectDetails.spaceId,
                        inline: EditorInlineSetObject(blockId: info.id, targetObjectID: objectDetails.id)
                    )
                )
            )
        } else if !FeatureFlags.fullInlineSetImpl {
            openSet(
                objectDetails.editorScreenData()
            )
        }
    }
}
