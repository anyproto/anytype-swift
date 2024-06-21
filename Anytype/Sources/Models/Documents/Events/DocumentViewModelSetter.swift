import Foundation
import Services
import AnytypeCore

protocol DocumentViewModelSetterProtocol: AnyObject {
    func objectViewUpdate(_ data: ObjectViewModel)
}

final class DocumentViewModelSetter: DocumentViewModelSetterProtocol {
    
    private let detailsStorage: ObjectDetailsStorage
    private let relationLinksStorage: RelationLinksStorageProtocol
    private let restrictionsContainer: ObjectRestrictionsContainer
    private let infoContainer: InfoContainerProtocol
    
    init(
        detailsStorage: ObjectDetailsStorage,
        relationLinksStorage: RelationLinksStorageProtocol,
        restrictionsContainer: ObjectRestrictionsContainer,
        infoContainer: InfoContainerProtocol
    ) {
        self.detailsStorage = detailsStorage
        self.relationLinksStorage = relationLinksStorage
        self.restrictionsContainer = restrictionsContainer
        self.infoContainer = infoContainer
    }
    
    // MARK: - ObjectViewModelSetterProtocol
    
    func objectViewUpdate(_ data: ObjectViewModel) {
        guard data.rootID.isNotEmpty else {
            anytypeAssertionFailure("Empty root id")
            return
        }
        
        let parsedBlocks = data.blocks.compactMap {
            BlockInformationConverter.convert(block: $0)
        }
        
        let parsedDetails: [ObjectDetails] = data.details.compactMap {
            ObjectDetails(id: $0.id, values: $0.details.fields)
        }
        
        buildBlocksTree(information: parsedBlocks, rootId: data.rootID, container: infoContainer)
        
        parsedDetails.forEach { detailsStorage.add(details: $0) }
        
        let relationLinks = data.relationLinks.map { RelationLink(middlewareRelationLink: $0) }
        relationLinksStorage.set(relationLinks: relationLinks)
        
        let restrinctions = MiddlewareObjectRestrictionsConverter.convertObjectRestrictions(middlewareRestrictions: data.restrictions)
        
        restrictionsContainer.restrinctions = restrinctions
    }
    
    // MARK: - Private
    
    private func buildBlocksTree(information: [BlockInformation], rootId: String, container: InfoContainerProtocol) {
        
        information.forEach { container.add($0) }
        let roots = information.filter { $0.id == rootId }

        guard roots.count != 0 else {
            anytypeAssertionFailure("Unknown situation. We can't have zero roots.")
            return
        }

        if roots.count != 1 {
            // this situation is not possible, but, let handle it.
            anytypeAssertionFailure(
                "We have several roots for our rootId. Not possible, but let us handle it."
            )
        }

        let rootId = roots[0].id

        _ = IndentationBuilder.build(container: container, id: rootId)
    }
}
