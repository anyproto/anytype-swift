import Foundation
import AnytypeCore
import Services

enum TypePropertiesMoveError: Error {
    case wrongDataForFromRow
    case wrongDataForToRow
    case noHeaderFound
    case emptySection
    case movingSectionToItself
}

protocol TypePropertiesMoveHandlerProtocol: Sendable {
    func onMove(from: IndexSet, to: Int, relationRows: [TypePropertiesRow], document: any BaseDocumentProtocol) async throws
}

final class TypePropertiesMoveHandler: Sendable {
    private let propertiesService: any PropertiesServiceProtocol = Container.shared.propertiesService()
    
    func onMove(from: Int, to: Int, relationRows: [TypePropertiesRow], document: any BaseDocumentProtocol) async throws {
        guard let fromRow = relationRows[safe: from], case let .relation(fromRelation) = fromRow else {
            anytypeAssertionFailure("Wrong data for fromRow", info: ["fromIndex": from.description, "rows": relationRows.description])
            throw TypePropertiesMoveError.wrongDataForFromRow
        }
        
        guard let toRow = relationRows[safe: to] else {
            anytypeAssertionFailure("Wrong data for toRow", info: ["toIndex": to.description, "rows": relationRows.description])
            throw TypePropertiesMoveError.wrongDataForToRow
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
    
    private func handleMoveToSection(_ section: TypePropertiesSectionRow, fromRelation: TypePropertiesRelationRow, relationRows: [TypePropertiesRow], document: any BaseDocumentProtocol) async throws {
        let toRow = try findToRowForHeader(section, fromRelation: fromRelation, relationRows: relationRows)
        switch toRow {
        case .relation(let toRelation):
            try await move(from: fromRelation, to: toRelation, document: document)
        case .header:
            throw TypePropertiesMoveError.emptySection
        case .emptyRow(let section):
            try await move(from: fromRelation, to: section, document: document)
        }
    }
    
    private func findToRowForHeader(_ header: TypePropertiesSectionRow, fromRelation: TypePropertiesRelationRow, relationRows: [TypePropertiesRow]) throws -> TypePropertiesRow {
        switch header {
        case .header:
            return try findRowClosestToSection(header, above: false, relationRows: relationRows)
        case .fieldsMenu:
            guard let headerIndex = relationRows.firstIndex(of: .header(header)) else {
                anytypeAssertionFailure("No header found", info: ["rows": relationRows.description])
                throw TypePropertiesMoveError.noHeaderFound
            }
            guard let fromIndex = relationRows.firstIndex(of: .relation(fromRelation)) else {
                anytypeAssertionFailure("Wrong data for fromRow", info: ["rows": relationRows.description])
                throw TypePropertiesMoveError.wrongDataForFromRow
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
    
    private func findRowClosestToSection(_ section: TypePropertiesSectionRow, above: Bool, relationRows: [TypePropertiesRow]) throws -> TypePropertiesRow {
        guard let headerIndex = relationRows.firstIndex(of: .header(section)) else {
            anytypeAssertionFailure("No section found", info: ["rows": relationRows.description])
            throw TypePropertiesMoveError.noHeaderFound
        }
        
        let closestRowIndex = above ? relationRows.index(before: headerIndex) : relationRows.index(after: headerIndex)
        guard let row = relationRows[safe: closestRowIndex] else {
            anytypeAssertionFailure("Empty section", info: ["rows": relationRows.description])
            throw TypePropertiesMoveError.emptySection
        }
        
        return row
    }
    
    
    // Move to empty section
    private func move(from: TypePropertiesRelationRow, to: TypePropertiesSectionRow, document: any BaseDocumentProtocol) async throws {
        guard let details = document.details else { return }
        
        
        switch from.section {
        case .header:
            guard let fromIndex = details.recommendedFeaturedRelations.firstIndex(of: from.relation.id) else { return }
            
            let fromRelation = details.recommendedFeaturedRelationsDetails[fromIndex]
            let newRecommendedRelations = [fromRelation]
            
            var newFeaturedRelations = details.recommendedFeaturedRelationsDetails
            newFeaturedRelations.remove(at: fromIndex)
            
            try await move(
                typeId: document.objectId,
                from: from.section,
                to: to,
                recommendedRelationIds: newRecommendedRelations,
                recommendedFeaturedRelationsIds: newFeaturedRelations,
                recommendedHiddenRelationsIds: details.recommendedHiddenRelationsDetails
            )
        case .fieldsMenu:
            guard let fromIndex = details.recommendedRelations.firstIndex(of: from.relation.id) else { return }
            
            let fromRelation = details.recommendedRelationsDetails[fromIndex]
            
            var newRecommendedRelations = details.recommendedRelationsDetails
            newRecommendedRelations.remove(at: fromIndex)
            
            switch to {
            case .header:
                let newFeaturedRelations = [fromRelation]
                
                try await move(
                    typeId: document.objectId,
                    from: from.section,
                    to: to,
                    recommendedRelationIds: newRecommendedRelations,
                    recommendedFeaturedRelationsIds: newFeaturedRelations,
                    recommendedHiddenRelationsIds: details.recommendedHiddenRelationsDetails
                )
            case .fieldsMenu:
                throw TypePropertiesMoveError.movingSectionToItself
            case .hidden:
                let newHiddenRelations = [fromRelation]
                
                try await move(
                    typeId: document.objectId,
                    from: from.section,
                    to: to,
                    recommendedRelationIds: newRecommendedRelations,
                    recommendedFeaturedRelationsIds: details.recommendedFeaturedRelationsDetails,
                    recommendedHiddenRelationsIds: newHiddenRelations
                )
            }
        case .hidden:
            guard let fromIndex = details.recommendedHiddenRelations.firstIndex(of: from.relation.id) else { return }
            
            let fromRelation = details.recommendedHiddenRelationsDetails[fromIndex]
            
            var newHiddenRelations = details.recommendedHiddenRelationsDetails
            newHiddenRelations.remove(at: fromIndex)
            
            let newRecommendedRelations = [fromRelation]
            
            try await move(
                typeId: document.objectId,
                from: from.section,
                to: to,
                recommendedRelationIds: newRecommendedRelations,
                recommendedFeaturedRelationsIds: details.recommendedFeaturedRelationsDetails,
                recommendedHiddenRelationsIds: newHiddenRelations
            )
        }
    }
    
    private func move(from: TypePropertiesRelationRow, to: TypePropertiesRelationRow, document: any BaseDocumentProtocol) async throws {
        guard from != to else { return }
        
        if from.section == to.section {
            try await moveWithinSection(from: from, to: to, document: document)
        } else {
            try await moveBetweenSections(from: from, to: to, document: document)
        }
    }
    
    private func moveWithinSection(from: TypePropertiesRelationRow, to: TypePropertiesRelationRow, document: any BaseDocumentProtocol) async throws {
        guard let details = document.details else { return }
        
        switch from.section {
        case .header:
            guard let fromIndex = details.recommendedFeaturedRelations.firstIndex(of: from.relation.id) else { return }
            guard let toIndex = details.recommendedFeaturedRelations.firstIndex(of: to.relation.id) else { return }
            var recommendedFeaturedRelationsDetails = details.recommendedFeaturedRelationsDetails
            recommendedFeaturedRelationsDetails.moveElement(from: fromIndex, to: toIndex)
            AnytypeAnalytics.instance().logReorderRelation(group: nil)
            
            try await move(
                typeId: document.objectId,
                from: from.section,
                to: to.section,
                recommendedRelationIds: details.recommendedRelationsDetails,
                recommendedFeaturedRelationsIds: recommendedFeaturedRelationsDetails,
                recommendedHiddenRelationsIds: details.recommendedHiddenRelationsDetails
            )
        case .fieldsMenu:
            guard let fromIndex = details.recommendedRelations.firstIndex(of: from.relation.id) else { return }
            guard let toIndex = details.recommendedRelations.firstIndex(of: to.relation.id) else { return }
            var recommendedRelationsDetails = details.recommendedRelationsDetails
            recommendedRelationsDetails.moveElement(from: fromIndex, to: toIndex)
            AnytypeAnalytics.instance().logReorderRelation(group: nil)
            
            try await move(
                typeId: document.objectId,
                from: from.section,
                to: to.section,
                recommendedRelationIds: recommendedRelationsDetails,
                recommendedFeaturedRelationsIds: details.recommendedFeaturedRelationsDetails,
                recommendedHiddenRelationsIds: details.recommendedHiddenRelationsDetails
            )
        case .hidden:
            guard let fromIndex = details.recommendedHiddenRelations.firstIndex(of: from.relation.id) else { return }
            guard let toIndex = details.recommendedHiddenRelations.firstIndex(of: to.relation.id) else { return }
            var recommendedHiddenRelationsDetails = details.recommendedHiddenRelationsDetails
            recommendedHiddenRelationsDetails.moveElement(from: fromIndex, to: toIndex)
            AnytypeAnalytics.instance().logReorderRelation(group: nil)
            
            try await move(
                typeId: document.objectId,
                from: from.section,
                to: to.section,
                recommendedRelationIds: details.recommendedRelationsDetails,
                recommendedFeaturedRelationsIds: details.recommendedFeaturedRelationsDetails,
                recommendedHiddenRelationsIds: recommendedHiddenRelationsDetails
            )
        }
    }
    
    private func moveBetweenSections(from: TypePropertiesRelationRow, to: TypePropertiesRelationRow, document: any BaseDocumentProtocol) async throws {
        guard let details = document.details else { return }
        
        switch from.section {
        case .header:
            guard let fromIndex = details.recommendedFeaturedRelations.firstIndex(of: from.relation.id) else { return }
            guard let toIndex = details.recommendedRelations.firstIndex(of: to.relation.id) else { return }
            
            let fromRelation = details.recommendedFeaturedRelationsDetails[fromIndex]
            
            var newFeaturedRelations = details.recommendedFeaturedRelationsDetails
            newFeaturedRelations.remove(at: fromIndex)
            
            var newRecommendedRelations = details.recommendedRelationsDetails
            newRecommendedRelations.insert(fromRelation, at: toIndex)
            
            try await move(
                typeId: document.objectId,
                from: from.section,
                to: to.section,
                recommendedRelationIds: newRecommendedRelations,
                recommendedFeaturedRelationsIds: newFeaturedRelations,
                recommendedHiddenRelationsIds: details.recommendedHiddenRelationsDetails
            )
        case .fieldsMenu:
            guard let fromIndex = details.recommendedRelations.firstIndex(of: from.relation.id) else { return }
            
            let fromRelation = details.recommendedRelationsDetails[fromIndex]
            
            var newRecommendedRelations = details.recommendedRelationsDetails
            newRecommendedRelations.remove(at: fromIndex)
            
            switch to.section {
            case .header:
                guard let toIndex = details.recommendedFeaturedRelations.firstIndex(of: to.relation.id) else { return }
                var newFeaturedRelations = details.recommendedFeaturedRelationsDetails
                newFeaturedRelations.insert(fromRelation, at: toIndex + 1) // Insert below target
                
                try await move(
                    typeId: document.objectId,
                    from: from.section,
                    to: to.section,
                    recommendedRelationIds: newRecommendedRelations,
                    recommendedFeaturedRelationsIds: newFeaturedRelations,
                    recommendedHiddenRelationsIds: details.recommendedHiddenRelationsDetails
                )
            case .fieldsMenu:
                throw TypePropertiesMoveError.movingSectionToItself
            case .hidden:
                let newHiddenRelations: [RelationDetails]
                    
                if details.recommendedHiddenRelations.isEmpty {
                    newHiddenRelations = [fromRelation]
                } else {
                    guard let toIndex = details.recommendedHiddenRelations.firstIndex(of: to.relation.id) else { return }
                    var recommendedHiddenRelationsDetails = details.recommendedHiddenRelationsDetails
                    recommendedHiddenRelationsDetails.insert(fromRelation, at: toIndex)
                    newHiddenRelations = recommendedHiddenRelationsDetails
                }
                
                try await move(
                    typeId: document.objectId,
                    from: from.section,
                    to: to.section,
                    recommendedRelationIds: newRecommendedRelations,
                    recommendedFeaturedRelationsIds: details.recommendedFeaturedRelationsDetails,
                    recommendedHiddenRelationsIds: newHiddenRelations
                )
            }
        case .hidden:
            guard let fromIndex = details.recommendedHiddenRelations.firstIndex(of: from.relation.id) else { return }
            guard let toIndex = details.recommendedRelations.firstIndex(of: to.relation.id) else { return }
            
            let fromRelation = details.recommendedHiddenRelationsDetails[fromIndex]
            
            var newHiddenRelations = details.recommendedHiddenRelationsDetails
            newHiddenRelations.remove(at: fromIndex)
            
            var newRecommendedRelations = details.recommendedRelationsDetails
            newRecommendedRelations.insert(fromRelation, at: toIndex + 1) // Insert below target
            
            try await move(
                typeId: document.objectId,
                from: from.section,
                to: to.section,
                recommendedRelationIds: newRecommendedRelations,
                recommendedFeaturedRelationsIds: details.recommendedFeaturedRelationsDetails,
                recommendedHiddenRelationsIds: newHiddenRelations
            )
        }
    }
    
    private func move(
        typeId: String,
        from: TypePropertiesSectionRow,
        to: TypePropertiesSectionRow,
        recommendedRelationIds: [RelationDetails],
        recommendedFeaturedRelationsIds: [RelationDetails],
        recommendedHiddenRelationsIds: [RelationDetails]
    ) async throws {
        AnytypeAnalytics.instance().logReorderRelation(group: from != to ? to.analyticsValue : nil)
        
        try await propertiesService.updateTypeRelations(
            typeId: typeId,
            recommendedRelations: recommendedRelationIds,
            recommendedFeaturedRelations: recommendedFeaturedRelationsIds,
            recommendedHiddenRelations: recommendedHiddenRelationsIds
        )
    }
}
