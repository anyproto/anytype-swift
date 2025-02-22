import Foundation
import AnytypeCore
import Services

enum TypeFieldsMoveError: Error {
    case wrongDataForFromRow
    case wrongDataForToRow
    case noHeaderFound
    case emptySection
    case movingSectionToItself
}

protocol TypeFieldsMoveHandlerProtocol {
    func onMove(from: IndexSet, to: Int, relationRows: [TypeFieldsRow], document: any BaseDocumentProtocol) async throws
}

final class TypeFieldsMoveHandler {
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    
    func onMove(from: Int, to: Int, relationRows: [TypeFieldsRow], document: any BaseDocumentProtocol) async throws {
        guard let fromRow = relationRows[safe: from], case let .relation(fromRelation) = fromRow else {
            anytypeAssertionFailure("Wrong data for fromRow", info: ["fromIndex": from.description, "rows": relationRows.description])
            throw TypeFieldsMoveError.wrongDataForFromRow
        }
        
        guard let toRow = relationRows[safe: to] else {
            anytypeAssertionFailure("Wrong data for toRow", info: ["toIndex": to.description, "rows": relationRows.description])
            throw TypeFieldsMoveError.wrongDataForToRow
        }
        
        switch toRow {
        case .emptyRow(let section):
            try await move(from: fromRelation, to: section, document: document)
        case .header(let section):
            try await handleMoveToSection(section, fromRelation: fromRelation, relationRows: relationRows, document: document)
        case .relation(let toRelation):
            try await move(from: fromRelation, to: toRelation, document: document)
        }
    }
    
    private func handleMoveToSection(_ section: TypeFieldsSectionRow, fromRelation: TypeFieldsRelationRow, relationRows: [TypeFieldsRow], document: any BaseDocumentProtocol) async throws {
        let toRow = try findToRowForHeader(section, fromRelation: fromRelation, relationRows: relationRows)
        switch toRow {
        case .relation(let toRelation):
            try await move(from: fromRelation, to: toRelation, document: document)
        case .header:
            throw TypeFieldsMoveError.emptySection
        case .emptyRow(let section):
            try await move(from: fromRelation, to: section, document: document)
        }
    }
    
    private func findToRowForHeader(_ header: TypeFieldsSectionRow, fromRelation: TypeFieldsRelationRow, relationRows: [TypeFieldsRow]) throws -> TypeFieldsRow {
        switch header {
        case .header:
            return try findRowClosestToSection(header, above: false, relationRows: relationRows)
        case .fieldsMenu:
            guard let headerIndex = relationRows.firstIndex(of: .header(header)) else {
                anytypeAssertionFailure("No header found", info: ["rows": relationRows.description])
                throw TypeFieldsMoveError.noHeaderFound
            }
            guard let fromIndex = relationRows.firstIndex(of: .relation(fromRelation)) else {
                anytypeAssertionFailure("Wrong data for fromRow", info: ["rows": relationRows.description])
                throw TypeFieldsMoveError.wrongDataForFromRow
            }
            
            let isMovingDownwards = fromIndex < headerIndex
            if isMovingDownwards {
                return try findRowClosestToSection(header, above: false, relationRows: relationRows)
            } else {
                return try findRowClosestToSection(header, above: true, relationRows: relationRows)
            }
        case .hidden:
            return try findRowClosestToSection(header, above: true, relationRows: relationRows)
        }
    }
    
    private func findRowClosestToSection(_ section: TypeFieldsSectionRow, above: Bool, relationRows: [TypeFieldsRow]) throws -> TypeFieldsRow {
        guard let headerIndex = relationRows.firstIndex(of: .header(section)) else {
            anytypeAssertionFailure("No section found", info: ["rows": relationRows.description])
            throw TypeFieldsMoveError.noHeaderFound
        }
        
        let closestRowIndex = above ? relationRows.index(before: headerIndex) : relationRows.index(after: headerIndex)
        guard let row = relationRows[safe: closestRowIndex] else {
            anytypeAssertionFailure("Empty section", info: ["rows": relationRows.description])
            throw TypeFieldsMoveError.emptySection
        }
        
        return row
    }
    
    
    // Move to empty section
    private func move(from: TypeFieldsRelationRow, to: TypeFieldsSectionRow, document: any BaseDocumentProtocol) async throws {
        guard let details = document.details else { return }
        
        
        switch from.section {
        case .header:
            guard let fromIndex = details.recommendedFeaturedRelations.firstIndex(of: from.relation.id) else { return }
            
            let fromRelation = details.recommendedFeaturedRelations[fromIndex]
            
            var newFeaturedRelations = details.recommendedFeaturedRelations
            newFeaturedRelations.remove(at: fromIndex)
            
            let newRecommendedRelations = [fromRelation]
            
            try await relationsService.updateTypeRelations(
                typeId: document.objectId,
                recommendedRelationIds: newRecommendedRelations,
                recommendedFeaturedRelationsIds: newFeaturedRelations,
                recommendedHiddenRelationsIds: details.recommendedHiddenRelations
            )
        case .fieldsMenu:
            guard let fromIndex = details.recommendedRelations.firstIndex(of: from.relation.id) else { return }
            
            let fromRelation = details.recommendedRelations[fromIndex]
            
            var newRecommendedRelations = details.recommendedRelations
            newRecommendedRelations.remove(at: fromIndex)
            
            switch to {
            case .header:
                let newFeaturedRelations = [fromRelation]
                
                try await relationsService.updateTypeRelations(
                    typeId: document.objectId,
                    recommendedRelationIds: newRecommendedRelations,
                    recommendedFeaturedRelationsIds: newFeaturedRelations,
                    recommendedHiddenRelationsIds: details.recommendedHiddenRelations
                )
            case .fieldsMenu:
                throw TypeFieldsMoveError.movingSectionToItself
            case .hidden:
                let newHiddenRelations = [fromRelation]
                
                try await relationsService.updateTypeRelations(
                    typeId: document.objectId,
                    recommendedRelationIds: newRecommendedRelations,
                    recommendedFeaturedRelationsIds: details.recommendedFeaturedRelations,
                    recommendedHiddenRelationsIds: newHiddenRelations
                )
            }
        case .hidden:
            guard let fromIndex = details.recommendedHiddenRelations.firstIndex(of: from.relation.id) else { return }
            
            let fromRelation = details.recommendedHiddenRelations[fromIndex]
            
            var newHiddenRelations = details.recommendedHiddenRelations
            newHiddenRelations.remove(at: fromIndex)
            
            let newRecommendedRelations = [fromRelation]
            
            try await relationsService.updateTypeRelations(
                typeId: document.objectId,
                recommendedRelationIds: newRecommendedRelations,
                recommendedFeaturedRelationsIds: details.recommendedFeaturedRelations,
                recommendedHiddenRelationsIds: newHiddenRelations
            )
        }
    }
    
    private func move(from: TypeFieldsRelationRow, to: TypeFieldsRelationRow, document: any BaseDocumentProtocol) async throws {
        guard from != to else { return }
        
        if from.section == to.section {
            try await moveWithinSection(from: from, to: to, document: document)
        } else {
            try await moveBetweenSections(from: from, to: to, document: document)
        }
    }
    
    private func moveWithinSection(from: TypeFieldsRelationRow, to: TypeFieldsRelationRow, document: any BaseDocumentProtocol) async throws {
        guard let details = document.details else { return }
        
        switch from.section {
        case .header:
            guard let fromIndex = details.recommendedFeaturedRelations.firstIndex(of: from.relation.id) else { return }
            guard let toIndex = details.recommendedFeaturedRelations.firstIndex(of: to.relation.id) else { return }
            var newRelations = details.recommendedFeaturedRelations
            newRelations.moveElement(from: fromIndex, to: toIndex)
            try await relationsService.updateRecommendedFeaturedRelations(typeId: document.objectId, relationIds: newRelations)
        case .fieldsMenu:
            guard let fromIndex = details.recommendedRelations.firstIndex(of: from.relation.id) else { return }
            guard let toIndex = details.recommendedRelations.firstIndex(of: to.relation.id) else { return }
            var newRelations = details.recommendedRelations
            newRelations.moveElement(from: fromIndex, to: toIndex)
            try await relationsService.updateRecommendedRelations(typeId: document.objectId, relationIds: newRelations)
        case .hidden:
            guard let fromIndex = details.recommendedHiddenRelations.firstIndex(of: from.relation.id) else { return }
            guard let toIndex = details.recommendedHiddenRelations.firstIndex(of: to.relation.id) else { return }
            var newRelations = details.recommendedHiddenRelations
            newRelations.moveElement(from: fromIndex, to: toIndex)
            try await relationsService.updateRecommendedHiddenRelations(typeId: document.objectId, relationIds: newRelations)
        }
    }
    
    private func moveBetweenSections(from: TypeFieldsRelationRow, to: TypeFieldsRelationRow, document: any BaseDocumentProtocol) async throws {
        guard let details = document.details else { return }
        
        switch from.section {
        case .header:
            guard let fromIndex = details.recommendedFeaturedRelations.firstIndex(of: from.relation.id) else { return }
            guard let toIndex = details.recommendedRelations.firstIndex(of: to.relation.id) else { return }
            
            let fromRelation = details.recommendedFeaturedRelations[fromIndex]
            
            var newFeaturedRelations = details.recommendedFeaturedRelations
            newFeaturedRelations.remove(at: fromIndex)
            
            var newRecommendedRelations = details.recommendedRelations
            newRecommendedRelations.insert(fromRelation, at: toIndex)
            
            try await relationsService.updateTypeRelations(
                typeId: document.objectId,
                recommendedRelationIds: newRecommendedRelations,
                recommendedFeaturedRelationsIds: newFeaturedRelations,
                recommendedHiddenRelationsIds: details.recommendedHiddenRelations
            )
        case .fieldsMenu:
            guard let fromIndex = details.recommendedRelations.firstIndex(of: from.relation.id) else { return }
            
            let fromRelation = details.recommendedRelations[fromIndex]
            
            var newRecommendedRelations = details.recommendedRelations
            newRecommendedRelations.remove(at: fromIndex)
            
            switch to.section {
            case .header:
                guard let toIndex = details.recommendedFeaturedRelations.firstIndex(of: to.relation.id) else { return }
                var newFeaturedRelations = details.recommendedFeaturedRelations
                newFeaturedRelations.insert(fromRelation, at: toIndex + 1) // Insert below target
                
                try await relationsService.updateTypeRelations(
                    typeId: document.objectId,
                    recommendedRelationIds: newRecommendedRelations,
                    recommendedFeaturedRelationsIds: newFeaturedRelations,
                    recommendedHiddenRelationsIds: details.recommendedHiddenRelations
                )
            case .fieldsMenu:
                throw TypeFieldsMoveError.movingSectionToItself
            case .hidden:
                guard let toIndex = details.recommendedHiddenRelations.firstIndex(of: to.relation.id) else { return }
                var newHiddenRelations = details.recommendedHiddenRelations
                newHiddenRelations.insert(fromRelation, at: toIndex)
                
                try await relationsService.updateTypeRelations(
                    typeId: document.objectId,
                    recommendedRelationIds: newRecommendedRelations,
                    recommendedFeaturedRelationsIds: details.recommendedFeaturedRelations,
                    recommendedHiddenRelationsIds: newHiddenRelations
                )
            }
        case .hidden:
            guard let fromIndex = details.recommendedHiddenRelations.firstIndex(of: from.relation.id) else { return }
            guard let toIndex = details.recommendedRelations.firstIndex(of: to.relation.id) else { return }
            
            let fromRelation = details.recommendedHiddenRelations[fromIndex]
            
            var newHiddenRelations = details.recommendedHiddenRelations
            newHiddenRelations.remove(at: fromIndex)
            
            var newRecommendedRelations = details.recommendedRelations
            newRecommendedRelations.insert(fromRelation, at: toIndex + 1) // Insert below target
            
            try await relationsService.updateTypeRelations(
                typeId: document.objectId,
                recommendedRelationIds: newRecommendedRelations,
                recommendedFeaturedRelationsIds: details.recommendedFeaturedRelations,
                recommendedHiddenRelationsIds: newHiddenRelations
            )
        }
    }
}
