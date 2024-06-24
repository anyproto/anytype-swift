import UIKit
import Services
import Combine
import SwiftUI

final class FeaturedRelationsBlockViewModel: BlockViewModelProtocol {
    let infoProvider: BlockModelInfomationProvider
    var info: BlockInformation { infoProvider.info }
    var hashable: AnyHashable { info.id }

    private let document: BaseDocumentProtocol
    private var featuredRelations: [Relation]
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
        self.featuredRelations = document.featuredRelationsForEditor
        self.collectionController = collectionController
        self.onRelationTap = onRelationValueTap
        
        document.featuredRelationsForEditorPublisher
            .receiveOnMain()
            .removeDuplicates()
            .sink { [weak self] newFeaturedRelations in
                guard let self else { return }
                if featuredRelations != newFeaturedRelations {
                    self.featuredRelations = newFeaturedRelations
                    collectionController.reconfigure(items: [.block(self)])
                }
            }.store(in: &cancellables)
    }
    
    func makeContentConfiguration(maxWidth _: CGFloat) -> UIContentConfiguration {
        return UIHostingConfiguration {
            EditorFeaturedRelationsView(
                relations: featuredRelations,
                onRelationTap: onRelationTap
            )
        }
        .minSize(height: 0)
        .background(info.backgroundColor?.backgroundColor.swiftColor ?? .Background.primary)
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
