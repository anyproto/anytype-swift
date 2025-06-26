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
    
    var parsedPropertiesPublisher: AnyPublisher<ParsedProperties, Never> {
        subscibeFor(update: [.relations])
            .compactMap { [weak self] _ in
                self?.parsedProperties
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
    
    var parsedPropertiesPublisherForType: AnyPublisher<ParsedProperties, Never> {
        subscibeFor(update: [.general, .details(id: objectId), .permissions]).compactMap { [weak self] _ in
            self?.buildParsedRelationsForType()
        }.eraseToAnyPublisher()
    }
    
    // Temporary design: Move to the dedicated TypeDocument later
    private func buildParsedRelationsForType() -> ParsedProperties {
        guard let details else { return .empty }
        
        let propertyDetailsStorage = Container.shared.propertyDetailsStorage()
        
        let recommendedRelations = propertyDetailsStorage
            .relationsDetails(ids: details.recommendedRelations, spaceId: spaceId)
            .filter { $0.key != BundledPropertyKey.description.rawValue }
        let recommendedFeaturedRelations = propertyDetailsStorage
            .relationsDetails(ids: details.recommendedFeaturedRelations, spaceId: spaceId)
            .filter { $0.key != BundledPropertyKey.description.rawValue }
        let recommendedHiddenRelations = propertyDetailsStorage
            .relationsDetails(ids: details.recommendedHiddenRelations, spaceId: spaceId)
            .filter { $0.key != BundledPropertyKey.description.rawValue }
        
        
        return Container.shared.propertiesBuilder().parsedProperties(
            objectRelations: [],
            objectFeaturedRelations: [],
            recommendedRelations: recommendedRelations,
            recommendedFeaturedRelations: recommendedFeaturedRelations,
            recommendedHiddenRelations: recommendedHiddenRelations,
            objectId: objectId,
            relationValuesIsLocked: !permissions.canEditRelationValues,
            storage: detailsStorage
        )
    }
}
