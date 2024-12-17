import Foundation
import AnytypeCore
import Services


protocol TypeFieldsMoveHandlerProtocol {
    func onMove(from: IndexSet, to: Int, relationRows: [TypeFieldsRow], document: any BaseDocumentProtocol)
}

final class TypeFieldsMoveHandler {
    @Injected(\.relationsService) var relationsService: any RelationsServiceProtocol
    
    
    func onMove(from: IndexSet, to: Int, relationRows: [TypeFieldsRow], document: any BaseDocumentProtocol) {
        guard from.count == 1 else {
            anytypeAssertionFailure("Non singular number of index for onMove", info: ["fromIndexes": from.description])
            return
        }
        
        guard let fromIndex = from.first else { return }
        guard let fromRow = relationRows[safe: fromIndex], case let .relation(fromRelation) = fromRow else {
            anytypeAssertionFailure("Wrong data for fromRow", info: ["fromIndex": fromIndex.description, "rows": relationRows.description])
            return
        }
        
        // Adjust 'to' index if moving downwards
        let adjustedTo = fromIndex < to ? to - 1 : to
        
        guard let toRow = relationRows[safe: adjustedTo],
              case let .relation(toRelation) = toRow else {
            anytypeAssertionFailure("Wrong data for toRow", info: ["toIndex": adjustedTo.description, "rows": relationRows.description])
            return
        }
        
        move(from: fromRelation, to: toRelation, document: document)
    }

    
    private func move(from: TypeFieldsRelationRow, to: TypeFieldsRelationRow, document: any BaseDocumentProtocol) {
        Task {
            if from.section == to.section {
                try await moveWithinSection(from: from, to: to, document: document)
            } else {
                try await moveBetweenSections(from: from, to: to, document: document)
            }
        }
    }
    
    private func moveWithinSection(from: TypeFieldsRelationRow, to: TypeFieldsRelationRow, document: any BaseDocumentProtocol) async throws {
        guard let details = document.details else { return }
        
        if from.section.isHeader {
            guard let fromIndex = details.recommendedFeaturedRelations.firstIndex(of: from.relation.id) else { return }
            guard let toIndex = details.recommendedFeaturedRelations.firstIndex(of: to.relation.id) else { return }
            var newRelations = details.recommendedFeaturedRelations
            newRelations.moveElement(from: fromIndex, to: toIndex)
            try await relationsService.updateRecommendedFeaturedRelations(typeId: document.objectId, relationIds: newRelations)
        } else {
            guard let fromIndex = details.recommendedRelations.firstIndex(of: from.relation.id) else { return }
            guard let toIndex = details.recommendedRelations.firstIndex(of: to.relation.id) else { return }
            var newRelations = details.recommendedRelations
            newRelations.moveElement(from: fromIndex, to: toIndex)
            try await relationsService.updateRecommendedRelations(typeId: document.objectId, relationIds: newRelations)
        }
    }
    
    private func moveBetweenSections(from: TypeFieldsRelationRow, to: TypeFieldsRelationRow, document: any BaseDocumentProtocol) async throws {
        guard let details = document.details else { return }
        
        if from.section.isHeader {
            guard let fromIndex = details.recommendedFeaturedRelations.firstIndex(of: from.relation.id) else { return }
            guard let toIndex = details.recommendedRelations.firstIndex(of: to.relation.id) else { return }
            
            let fromRelation = details.recommendedFeaturedRelations[fromIndex]
            
            var newFeaturedRelations = details.recommendedFeaturedRelations
            newFeaturedRelations.remove(at: fromIndex)
            
            var newRecommendedRelations = details.recommendedRelations
            newRecommendedRelations.insert(fromRelation, at: toIndex + 1)
            
            try await relationsService.updateTypeRelations(typeId: document.objectId, recommendedRelationIds: newRecommendedRelations, recommendedFeaturedRelationsIds: newFeaturedRelations)
        } else {
            guard let fromIndex = details.recommendedRelations.firstIndex(of: from.relation.id) else { return }
            guard let toIndex = details.recommendedFeaturedRelations.firstIndex(of: to.relation.id) else { return }
            
            let fromRelation = details.recommendedRelations[fromIndex]
            
            var newRecommendedRelations = details.recommendedRelations
            newRecommendedRelations.remove(at: fromIndex)
            
            var newFeaturedRelations = details.recommendedFeaturedRelations
            newFeaturedRelations.insert(fromRelation, at: toIndex)
            try await relationsService.updateTypeRelations(typeId: document.objectId, recommendedRelationIds: newRecommendedRelations, recommendedFeaturedRelationsIds: newFeaturedRelations)
        }
    }
}
