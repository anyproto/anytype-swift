import Foundation
import Services
import AnytypeCore
import Combine

extension BaseDocumentProtocol {
    // without description, type and editable setOf if needed
    var featuredRelationsForEditorPublisher: AnyPublisher<[Property], Never> {
        parsedPropertiesPublisher
            .map { [weak self] parsedProperties -> [Property] in
                guard let self else { return [] }
                
                var enhancedRelations = parsedProperties.legacyFeaturedProperties.isNotEmpty ? parsedProperties.legacyFeaturedProperties : parsedProperties.featuredProperties
                
                enhancedRelations.reorder(
                    by: [ BundledPropertyKey.setOf.rawValue ]
                ) { $0.key }
                
                // Do not show Description featured relation, we show it in dedicated block
                enhancedRelations.removeAll { $0.key == BundledPropertyKey.description.rawValue }
                // Do not show empty (back)Links 
                enhancedRelations.removeAll { $0.links.isNotNil && !$0.hasValue }
                
                let setOfIndex = enhancedRelations.firstIndex { $0.key == BundledPropertyKey.setOf.rawValue }
                if permissions.canEditRelationValues,
                   let setOfIndex,
                   let editableRelation = enhancedRelations[setOfIndex].editableRelation
                {
                    enhancedRelations[setOfIndex] = editableRelation
                }
                
                return enhancedRelations
            }.eraseToAnyPublisher()
    }
    
    var featuredRelationsForEditor: [Property] {
        var enhancedRelations = parsedProperties.legacyFeaturedProperties.isNotEmpty ? parsedProperties.legacyFeaturedProperties : parsedProperties.featuredProperties
        
        enhancedRelations.reorder(
            by: [ BundledPropertyKey.setOf.rawValue ]
        ) { $0.key }
        
        enhancedRelations.removeAll { relation in
            relation.key == BundledPropertyKey.description.rawValue ||
            (relation.links.isNotNil && !relation.hasValue)
        }
        
        let setOfIndex = enhancedRelations.firstIndex { $0.key == BundledPropertyKey.setOf.rawValue }
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
    
    var blockLayoutDetailsPublisher: AnyPublisher<[String: BlockLayoutDetails], Never> {
        childrenPublisher
            .map { EditorCollectionFlowLayout.blockLayoutDetails(blockInfos: $0) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
