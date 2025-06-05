import UIKit
import Services
import Combine
import SwiftUI

final class FeaturedPropertiesBlockViewModel: BlockViewModelProtocol {
    let infoProvider: BlockModelInfomationProvider
    nonisolated var info: BlockInformation { infoProvider.info }
    nonisolated var hashable: AnyHashable { info.id }

    private let document: any BaseDocumentProtocol
    private var featuredRelations: [Relation]
    private let onRelationTap: (Relation) -> Void
    private let collectionController: any EditorCollectionReloadable
    
    private var cancellables = [AnyCancellable]()
    
    init(
        infoProvider: BlockModelInfomationProvider,
        document: some BaseDocumentProtocol,
        collectionController: some EditorCollectionReloadable,
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
    
    func makeContentConfiguration(maxWidth _: CGFloat) -> any UIContentConfiguration {
        return UIHostingConfiguration {
            EditorFeaturedPropertiesView(
                relations: featuredRelations,
                onRelationTap: onRelationTap
            )
        }
        .minSize(height: 0)
        .margins(.vertical, 0)
        .margins(.horizontal, 20)
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
