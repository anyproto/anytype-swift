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
            var newFeaturedRelations = details.recommendedFeaturedRelationsDetails
            guard let fromIndex = newFeaturedRelations.firstIndex(where: { $0.id == from.relation.id }) else { return }
            let fromRelation = newFeaturedRelations.remove(at: fromIndex)
            let newRecommendedRelations = [fromRelation]

            try await move(
                typeId: document.objectId,
                from: from.section,
                to: to,
                recommendedRelationIds: newRecommendedRelations,
                recommendedFeaturedRelationsIds: newFeaturedRelations,
                recommendedHiddenRelationsIds: details.recommendedHiddenRelationsDetails
            )
        case .fieldsMenu:
            var newRecommendedRelations = details.recommendedRelationsDetails
            guard let fromIndex = newRecommendedRelations.firstIndex(where: { $0.id == from.relation.id }) else { return }
            let fromRelation = newRecommendedRelations.remove(at: fromIndex)

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
            var newHiddenRelations = details.recommendedHiddenRelationsDetails
            guard let fromIndex = newHiddenRelations.firstIndex(where: { $0.id == from.relation.id }) else { return }
            let fromRelation = newHiddenRelations.remove(at: fromIndex)
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
            var recommendedFeaturedRelationsDetails = details.recommendedFeaturedRelationsDetails
            guard let fromIndex = recommendedFeaturedRelationsDetails.firstIndex(where: { $0.id == from.relation.id }),
                  let toIndex = recommendedFeaturedRelationsDetails.firstIndex(where: { $0.id == to.relation.id }) else { return }
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
            var recommendedRelationsDetails = details.recommendedRelationsDetails
            guard let fromIndex = recommendedRelationsDetails.firstIndex(where: { $0.id == from.relation.id }),
                  let toIndex = recommendedRelationsDetails.firstIndex(where: { $0.id == to.relation.id }) else { return }
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
            var recommendedHiddenRelationsDetails = details.recommendedHiddenRelationsDetails
            guard let fromIndex = recommendedHiddenRelationsDetails.firstIndex(where: { $0.id == from.relation.id }),
                  let toIndex = recommendedHiddenRelationsDetails.firstIndex(where: { $0.id == to.relation.id }) else { return }
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
            var newFeaturedRelations = details.recommendedFeaturedRelationsDetails
            guard let fromIndex = newFeaturedRelations.firstIndex(where: { $0.id == from.relation.id }) else { return }
            let fromRelation = newFeaturedRelations.remove(at: fromIndex)

            var newRecommendedRelations = details.recommendedRelationsDetails
            guard let toIndex = newRecommendedRelations.firstIndex(where: { $0.id == to.relation.id }) else { return }
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
            var newRecommendedRelations = details.recommendedRelationsDetails
            guard let fromIndex = newRecommendedRelations.firstIndex(where: { $0.id == from.relation.id }) else { return }
            let fromRelation = newRecommendedRelations.remove(at: fromIndex)

            switch to.section {
            case .header:
                var newFeaturedRelations = details.recommendedFeaturedRelationsDetails
                guard let toIndex = newFeaturedRelations.firstIndex(where: { $0.id == to.relation.id }) else { return }
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
                var newHiddenRelations = details.recommendedHiddenRelationsDetails
                if newHiddenRelations.isEmpty {
                    newHiddenRelations = [fromRelation]
                } else {
                    guard let toIndex = newHiddenRelations.firstIndex(where: { $0.id == to.relation.id }) else { return }
                    newHiddenRelations.insert(fromRelation, at: toIndex)
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
            var newHiddenRelations = details.recommendedHiddenRelationsDetails
            guard let fromIndex = newHiddenRelations.firstIndex(where: { $0.id == from.relation.id }) else { return }
            let fromRelation = newHiddenRelations.remove(at: fromIndex)

            var newRecommendedRelations = details.recommendedRelationsDetails
            guard let toIndex = newRecommendedRelations.firstIndex(where: { $0.id == to.relation.id }) else { return }
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
        recommendedRelationIds: [PropertyDetails],
        recommendedFeaturedRelationsIds: [PropertyDetails],
        recommendedHiddenRelationsIds: [PropertyDetails]
    ) async throws {
        AnytypeAnalytics.instance().logReorderRelation(group: from != to ? to.analyticsValue : nil)
        
        try await propertiesService.updateTypeProperties(
            typeId: typeId,
            recommendedProperties: recommendedRelationIds,
            recommendedFeaturedProperties: recommendedFeaturedRelationsIds,
            recommendedHiddenProperties: recommendedHiddenRelationsIds
        )
    }
}
