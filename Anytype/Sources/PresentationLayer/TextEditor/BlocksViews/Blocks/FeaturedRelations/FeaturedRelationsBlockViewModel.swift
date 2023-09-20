import UIKit
import Services
import Combine

final class FeaturedRelationsBlockViewModel: BlockViewModelProtocol {
    let infoProvider: BlockModelInfomationProvider
    var info: BlockInformation { infoProvider.info }
    var hashable: AnyHashable { info.id }

    private let document: BaseDocumentProtocol
    private var featuredRelationValues: [Relation]
    private let onRelationTap: (Relation) -> Void
    private let collectionController: EditorCollectionReloadable
    
    private var cancellables = [AnyCancellable]()
    
    init(
        infoProvider: BlockModelInfomationProvider,
        document: BaseDocumentProtocol,
        collectionController: EditorCollectionReloadable,
        onRelationValueTap: @escaping (Relation) -> Void
    ) {
        self.infoProvider = infoProvider
        self.document = document
        self.featuredRelationValues = document.featuredRelationsForEditor
        self.collectionController = collectionController
        self.onRelationTap = onRelationValueTap
        
        document.featuredRelationsForEditorPublisher.sink { [weak self] newFeaturedRelations in
            guard let self else { return }
            if featuredRelationValues != newFeaturedRelations {
                self.featuredRelationValues = newFeaturedRelations
                collectionController.reconfigure(items: [.block(self)])
            }
        }.store(in: &cancellables)
    }
    
    func makeContentConfiguration(maxWidth _: CGFloat) -> UIContentConfiguration {
        let relationViewModels = featuredRelationValues.map(RelationItemModel.init)
        let objectType = document.details?.objectType
        
        return FeaturedRelationsBlockContentConfiguration(
            featuredRelations: relationViewModels,
            type: objectType?.name ?? "",
            alignment: info.horizontalAlignment.asNSTextAlignment,
            onRelationTap: { [weak self] item in
                self?.featuredRelationValues
                    .first { $0.key == item.key }
                    .map { self?.onRelationTap($0) }
            },
            heightDidChanged: { [weak self] in
                guard let self else { return }
                collectionController.itemDidChangeFrame(item: .block(self))
            }
        ).cellBlockConfiguration(
            dragConfiguration: nil,
            styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
