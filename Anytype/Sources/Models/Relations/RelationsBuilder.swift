import Foundation
import Services
import SwiftProtobuf
import UIKit
import AnytypeCore

protocol RelationsBuilderProtocol: AnyObject {
    func parsedRelations(
        objectRelations: [RelationDetails],
        objectFeaturedRelations: [RelationDetails],
        recommendedRelations: [RelationDetails],
        recommendedFeaturedRelations: [RelationDetails],
        recommendedHiddenRelations: [RelationDetails],
        objectId: String,
        relationValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> ParsedRelations
}

final class RelationsBuilder: RelationsBuilderProtocol {
    
    @Injected(\.singleRelationBuilder)
    private var builder: any SingleRelationBuilderProtocol
    
    func parsedRelations(
        objectRelations: [RelationDetails],
        objectFeaturedRelations: [RelationDetails],
        recommendedRelations: [RelationDetails],
        recommendedFeaturedRelations: [RelationDetails],
        recommendedHiddenRelations: [RelationDetails],
        objectId: String,
        relationValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> ParsedRelations {
        guard let objectDetails = storage.get(id: objectId) else { return .empty }
        
        let systemRelations = buildSystemRelations(relationDetails: objectRelations, objectDetails: objectDetails, storage: storage)
        
        let objectRelations = buildRelations(
            relationDetails: objectRelations,
            objectDetails: objectDetails,
            isFeatured: false,
            relationValuesIsLocked: relationValuesIsLocked,
            storage: storage
        )
        
        let legacyFeaturedRelations = buildRelations(
            relationDetails: objectFeaturedRelations,
            objectDetails: objectDetails,
            isFeatured: true,
            relationValuesIsLocked: relationValuesIsLocked,
            hackGlobalName: true,
            storage: storage
        ).filter { !recommendedHiddenRelations.map(\.id).contains($0.id) }
        
        let featuredRelations = buildRelations(
            relationDetails: recommendedFeaturedRelations,
            objectDetails: objectDetails,
            isFeatured: true,
            relationValuesIsLocked: relationValuesIsLocked,
            hackGlobalName: true,
            storage: storage
        ).filter { !recommendedHiddenRelations.map(\.id).contains($0.id) }
        
        let mainSidebarRelations = buildRelations(
            relationDetails: recommendedRelations,
            objectDetails: objectDetails,
            isFeatured: false,
            relationValuesIsLocked: relationValuesIsLocked,
            storage: storage
        ).filter { !recommendedHiddenRelations.map(\.id).contains($0.id) }
        
        let hiddenRalations = buildRelations(
            relationDetails: recommendedHiddenRelations,
            objectDetails: objectDetails,
            isFeatured: false,
            relationValuesIsLocked: relationValuesIsLocked,
            storage: storage
        )
        
        let allConflictedRelations = objectRelations
            .filter {
                !mainSidebarRelations.map(\.id).contains($0.id) &&
                !featuredRelations.map(\.id).contains($0.id) &&
                !recommendedHiddenRelations.map(\.id).contains($0.id)
            }
        
        let deletedRelations = allConflictedRelations.filter { $0.isDeleted }
        
        let conflictedRelationsWithoutDeleted = allConflictedRelations.filter { !$0.isDeleted }
        let systemConflictedRelations = conflictedRelationsWithoutDeleted.filter { BundledRelationKey.systemKeys.map(\.rawValue).contains($0.key) }
        let conflictedRelations = conflictedRelationsWithoutDeleted.filter { !BundledRelationKey.systemKeys.map(\.rawValue).contains($0.key) }
        
        let sidebarRelations = mainSidebarRelations + systemConflictedRelations
        
        return ParsedRelations(
            featuredRelations: featuredRelations,
            sidebarRelations: sidebarRelations,
            hiddenRelations: hiddenRalations,
            conflictedRelations: conflictedRelations,
            deletedRelations: deletedRelations,
            systemRelations: systemRelations,
            legacyFeaturedRelations: legacyFeaturedRelations
        )
    }
    
    private func buildRelations(
        relationDetails: [RelationDetails],
        objectDetails: ObjectDetails,
        isFeatured: Bool,
        relationValuesIsLocked: Bool,
        hackGlobalName: Bool = false,
        storage: ObjectDetailsStorage
    ) -> [Relation] {
        var relations: [Relation] = relationDetails.compactMap { relation in
            guard isRelationCanBeAddedToList(relation) else {
                return nil
            }
            return builder.relation(
                relationDetails: relation,
                details: objectDetails,
                isFeatured: isFeatured,
                relationValuesIsLocked: relationValuesIsLocked,
                storage: storage
            )
        }
        
        if hackGlobalName {
            hackGlobalNameValue(
                objectRelations: relationDetails,
                objectDetails: objectDetails,
                relationValuesIsLocked: relationValuesIsLocked,
                storage: storage
            )
            .flatMap { relations.append($0) }
        }

        return relations
    }
    
    private func buildSystemRelations(
        relationDetails: [RelationDetails],
        objectDetails: ObjectDetails,
        storage: ObjectDetailsStorage
    ) -> [Relation] {
        return relationDetails.compactMap { relation in
            guard BundledRelationKey.systemKeys.map(\.rawValue).contains(relation.key) else {
                return nil
            }
            return builder.relation(
                relationDetails: relation,
                details: objectDetails,
                isFeatured: false,
                relationValuesIsLocked: true,
                storage: storage
            )
        }
    }
    
    private func isRelationCanBeAddedToList(_ relation: RelationDetails) -> Bool {
        guard !relation.isHidden else { return false }
        
        // We are filtering out description from the list of relations
        guard relation.key != BundledRelationKey.description.rawValue else { return false }
        
        // See hackGlobalNameValue
        guard relation.key != BundledRelationKey.globalName.rawValue && relation.key != BundledRelationKey.identity.rawValue else {
            return false
        }
        
        return true
    }
    
    //fallback to identiy if globalName is empty
    private func hackGlobalNameValue(
        objectRelations: [RelationDetails],
        objectDetails: ObjectDetails,
        relationValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Relation? {
        if let globaName = relationForKey(
            key: BundledRelationKey.globalName.rawValue,
            objectRelations: objectRelations,
            objectDetails: objectDetails,
            isFeatured: true,
            relationValuesIsLocked: relationValuesIsLocked,
            storage: storage
        ), globaName.hasValue { return globaName }
        
        if let identity = relationForKey(
            key: BundledRelationKey.identity.rawValue,
            objectRelations: objectRelations,
            objectDetails: objectDetails,
            isFeatured: true,
            relationValuesIsLocked: relationValuesIsLocked,
            storage: storage
        ), identity.hasValue { return identity }
        
        return nil
    }
    
    private func relationForKey(
        key: String,
        objectRelations: [RelationDetails],
        objectDetails: ObjectDetails,
        isFeatured: Bool,
        relationValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Relation? {
        guard let details = objectRelations.first(where: { $0.key == key }) else {
            return nil
        }
        
        return builder.relation(
            relationDetails: details,
            details: objectDetails,
            isFeatured: isFeatured,
            relationValuesIsLocked: relationValuesIsLocked,
            storage: storage
        )
    }
}

extension Container {
    var relationsBuilder: Factory<any RelationsBuilderProtocol> {
        self { RelationsBuilder() }.shared
    }
}
