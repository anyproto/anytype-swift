import Services
import Combine
import UIKit
import AnytypeCore

final class ObjectDetailsInfomationProvider {
    @Published private(set) var details: ObjectDetails?
    
    private let detailsStorage: ObjectDetailsStorage
    private let targetObjectId: String
    private var subscription: AnyCancellable?
    
    init(
        detailsStorage: ObjectDetailsStorage,
        targetObjectId: String,
        details: ObjectDetails?
    ) {
        self.detailsStorage = detailsStorage
        self.targetObjectId = targetObjectId
        self.details = details
        
        setupPublisher()
    }
    
    private func setupPublisher() {
        subscription = detailsStorage
            .publisherFor(id: targetObjectId)
            .sink { [weak self] in $0.map { self?.details = $0 } }
    }
}

final class DataViewBlockViewModel: BlockViewModelProtocol {

    let blockInformationProvider: BlockModelInfomationProvider
    let objectDetailsProvider: ObjectDetailsInfomationProvider
    
    private let showFailureToast: (_ message: String) -> ()
    private let openSet: (EditorScreenData) -> ()
    private weak var reloadable: EditorCollectionReloadable?
    
    var info: BlockInformation { blockInformationProvider.info }

    var hashable: AnyHashable { info.id }
    var detailsSubscription: AnyCancellable?

    init(
        blockInformationProvider: BlockModelInfomationProvider,
        objectDetailsProvider: ObjectDetailsInfomationProvider,
        reloadable: EditorCollectionReloadable?,
        showFailureToast: @escaping (_ message: String) -> (),
        openSet: @escaping (EditorScreenData) -> ()
    ) {
        self.blockInformationProvider = blockInformationProvider
        self.objectDetailsProvider = objectDetailsProvider
        self.reloadable = reloadable
        self.showFailureToast = showFailureToast
        self.openSet = openSet
        
        detailsSubscription = objectDetailsProvider
            .$details
            .removeDuplicates()
            .receiveOnMain()
            .sink { [weak self] _ in
            guard let self = self else { return }
            let selfItem = EditorItem.block(self)
            self.reloadable?.reconfigure(items: [selfItem])
        }
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        guard case let .dataView(data) = info.content, 
                !(objectDetailsProvider.details?.isDeleted ?? false) else {
            return NonExistentBlockViewModel(info: info)
                .makeContentConfiguration(maxWidth: maxWidth)
        }
        
        let isCollection = data.isCollection
        
        let content: DataViewBlockContent
        let subtitle = isCollection ? Loc.Content.DataView.InlineCollection.subtitle : Loc.Content.DataView.InlineSet.subtitle
        let placeholder = isCollection ? Loc.Content.DataView.InlineCollection.untitled : Loc.Content.DataView.InlineSet.untitled
        if let objectDetails = objectDetailsProvider.details {
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
            styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        guard let objectDetails = objectDetailsProvider.details else {
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
