import Foundation
import Services
import AnytypeCore
import Combine

extension BaseDocumentProtocol {
    // without description, type and editable setOf if needed
    var featuredRelationsForEditorPublisher: AnyPublisher<[Relation], Never> {
        parsedRelationsPublisher
            .map { [weak self] parsedRelations -> [Relation] in
                guard let self else { return [] }
                
                var enhancedRelations = parsedRelations.legacyFeaturedRelations.isNotEmpty ? parsedRelations.legacyFeaturedRelations : parsedRelations.featuredRelations
                
                enhancedRelations.reorder(
                    by: [ BundledRelationKey.setOf.rawValue ]
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
        var enhancedRelations = parsedRelations.legacyFeaturedRelations.isNotEmpty ? parsedRelations.legacyFeaturedRelations : parsedRelations.featuredRelations
        
        enhancedRelations.reorder(
            by: [ BundledRelationKey.setOf.rawValue ]
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
}
