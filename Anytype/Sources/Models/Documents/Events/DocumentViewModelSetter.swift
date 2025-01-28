import Foundation
import Services
import AnytypeCore

protocol DocumentViewModelSetterProtocol: AnyObject {
    func objectViewUpdate(_ data: ObjectViewModel)
}

final class DocumentViewModelSetter: DocumentViewModelSetterProtocol {
    
    @Injected(\.mentionTextUpdateHandler)
    private var mentionTextUpdateHandler: any MentionTextUpdateHandlerProtocol
    
    private let detailsStorage: ObjectDetailsStorage
    private let restrictionsContainer: ObjectRestrictionsContainer
    private let infoContainer: any InfoContainerProtocol
    
    init(
        detailsStorage: ObjectDetailsStorage,
        restrictionsContainer: ObjectRestrictionsContainer,
        infoContainer: some InfoContainerProtocol
    ) {
        self.detailsStorage = detailsStorage
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
        
        let rootDetails = parsedDetails.first { $0.id == data.rootID }
        
        buildBlocksTree(information: parsedBlocks, rootId: data.rootID, container: infoContainer, layout: rootDetails?.layoutValue)
        
        parsedDetails.forEach { detailsStorage.add(details: $0) }
        
        
        let restrinctions = MiddlewareObjectRestrictionsConverter.convertObjectRestrictions(middlewareRestrictions: data.restrictions)
        
        restrictionsContainer.restrictions = restrinctions
        
        mentionTextUpdateHandler.updateMentionsTextsIfNeeded(
            objectId: data.rootID,
            infoContainer: infoContainer,
            detailsStorage: detailsStorage
        )
    }
    
    // MARK: - Private
    
    private func buildBlocksTree(information: [BlockInformation], rootId: String, container: any InfoContainerProtocol, layout: DetailsLayout?) {
        
        information.forEach { container.add($0) }
        let roots = information.filter { $0.id == rootId }

        guard roots.count != 0 else {
            anytypeAssertionFailure(
                "Unknown situation. We can't have zero roots.",
                info: ["layout": layout?.rawValue.description ?? "Unknown"]
            )
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
