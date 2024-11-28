import Foundation
import Services
import AnytypeCore
import Combine

extension BaseDocumentProtocol {
    // without description, type and editable setOf if needed
    var featuredRelationsForEditorPublisher: AnyPublisher<[Relation], Never> {
        parsedRelationsPublisher
            .map { [weak self] q -> [Relation] in
                guard let self else { return [] }
                
                var enhancedRelations = q.featuredRelations
                
                enhancedRelations.reorder(
                    by: [
                        BundledRelationKey.type.rawValue,
                        BundledRelationKey.setOf.rawValue
                    ]
                ) { $0.key }
                
                // Do not show Description featured relation, we show it in dedicated block
                enhancedRelations.removeAll { $0.key == BundledRelationKey.description.rawValue }
                // Do not show empty (back)Links 
                enhancedRelations.removeAll { $0.links.isNotNil && !$0.hasValue }
                
                let setOfIndex = enhancedRelations.firstIndex { $0.key == BundledRelationKey.setOf.rawValue }
                if permissions.canEditRelationValues,
                   let setOfIndex,
                   let editableRelation = enhancedRelations[setOfIndex].editableRelation
                {
                    enhancedRelations[setOfIndex] = editableRelation
                }
                
                return enhancedRelations
            }.eraseToAnyPublisher()
    }
    
    var featuredRelationsForEditor: [Relation] {
        
        var enhancedRelations = parsedRelations.featuredRelations
        
        enhancedRelations.reorder(
            by: [
                BundledRelationKey.type.rawValue,
                BundledRelationKey.setOf.rawValue
            ]
        ) { $0.key }
        
        enhancedRelations.removeAll { relation in
            relation.key == BundledRelationKey.description.rawValue ||
            (relation.links.isNotNil && !relation.hasValue)
        }
        
        let setOfIndex = enhancedRelations.firstIndex { $0.key == BundledRelationKey.setOf.rawValue }
        if permissions.canEditRelationValues,
           let setOfIndex,
           let editableRelation = enhancedRelations[setOfIndex].editableRelation
        {
            enhancedRelations[setOfIndex] = editableRelation
        }
        
        return enhancedRelations
    }
    
    var flattenBlockIds: AnyPublisher<[String], Never> {
        childrenPublisher
            .map { $0.map { $0.id } }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var layoutDetailsPublisher: AnyPublisher<[AnyHashable: RowInformation], Never> {
        childrenPublisher
            .map { layoutDetails(for: $0) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func buildParsedRelationsForType() -> ParsedRelations {
        guard let details else { return .empty }
        
        let relationDetailsStorage = Container.shared.relationDetailsStorage()
        
        let recommendedRelations = relationDetailsStorage
            .relationsDetails(ids: details.recommendedRelations, spaceId: spaceId)
            .filter { $0.key != BundledRelationKey.description.rawValue }
        let recommendedFeaturedRelations = relationDetailsStorage
            .relationsDetails(ids: details.recommendedFeaturedRelations, spaceId: spaceId)
            .filter { $0.key != BundledRelationKey.description.rawValue }
        
        return Container.shared.relationsBuilder().parsedRelations(
            objectRelationDetails: [],
            typeRelationDetails: recommendedRelations,
            featuredTypeRelationsDetails: recommendedFeaturedRelations,
            objectId: objectId,
            relationValuesIsLocked: !permissions.canEditRelationValues,
            storage: detailsStorage
        )
    }
}
