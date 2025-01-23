import Foundation
import Combine
import Services

extension BaseDocumentProtocol {
    
    func subscribeForDetails(objectId: String) -> AnyPublisher<ObjectDetails, Never> {
        subscibeFor(update: [.details(id: objectId)])
            .compactMap { [weak self] _ in
                self?.detailsStorage.get(id: objectId)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func subscribeForBlockInfo(blockId: String) -> AnyPublisher
    <BlockInformation, Never> {
        subscibeFor(update: [.block(blockId: blockId), .unhandled(blockId: blockId)])
            .compactMap { [weak self] _ in
                self?.infoContainer.get(id: blockId)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var resetBlocksPublisher: AnyPublisher<Set<String>, Never> {
        syncPublisher
            .map { updates in
                let ids = updates.compactMap { update in
                    switch update {
                    case .block(let blockId):
                        return blockId
                    default:
                        return nil
                    }
                }
                return Set(ids)
            }
            .filter { $0.isNotEmpty }
            .eraseToAnyPublisher()
    }
    
    var childrenPublisher: AnyPublisher<[BlockInformation], Never> {
        subscibeFor(update: [.children])
            .compactMap { [weak self] _ in
                self?.children
            }
            .eraseToAnyPublisher()
    }
    
    var detailsPublisher: AnyPublisher<ObjectDetails, Never> {
        subscribeForDetails(objectId: objectId)
    }
    
    var parsedRelationsPublisher: AnyPublisher<ParsedRelations, Never> {
        subscibeFor(update: [.relations])
            .compactMap { [weak self] _ in
                self?.parsedRelations
            }
            .eraseToAnyPublisher()
    }
    
    var permissionsPublisher: AnyPublisher<ObjectPermissions, Never> {
        subscibeFor(update: [.permissions])
            .compactMap { [weak self] _ in
                self?.permissions
            }
            .eraseToAnyPublisher()
    }
    
    var parsedRelationsPublisherForType: AnyPublisher<ParsedRelations, Never> {
        subscibeFor(update: [.general, .details(id: objectId), .permissions]).compactMap { [weak self] _ in
            self?.buildParsedRelationsForType()
        }.eraseToAnyPublisher()
    }
    
    // Temporary design: Move to the dedicated TypeDocument later
    private func buildParsedRelationsForType() -> ParsedRelations {
        guard let details else { return .empty }
        
        let relationDetailsStorage = Container.shared.relationDetailsStorage()
        
        let recommendedRelations = relationDetailsStorage
            .relationsDetails(ids: details.recommendedRelations, spaceId: spaceId)
            .filter { $0.key != BundledRelationKey.description.rawValue }
        let recommendedFeaturedRelations = relationDetailsStorage
            .relationsDetails(ids: details.recommendedFeaturedRelations, spaceId: spaceId)
            .filter { $0.key != BundledRelationKey.description.rawValue }
        
        return Container.shared.relationsBuilder().parsedRelations(
            objectRelations: [],
            recommendedRelations: recommendedRelations,
            recommendedFeaturedRelations: recommendedFeaturedRelations,
            objectId: objectId,
            relationValuesIsLocked: !permissions.canEditRelationValues,
            storage: detailsStorage
        )
    }
}
