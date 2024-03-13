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
                
                enhancedRelations.removeAll { relation in
                    relation.key == BundledRelationKey.description.rawValue
                }
                
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
}
