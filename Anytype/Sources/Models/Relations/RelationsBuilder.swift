import Foundation
import Services
import SwiftProtobuf
import UIKit
import AnytypeCore

protocol RelationsBuilderProtocol: AnyObject {
    func parsedRelations(
        objectRelationDetails: [RelationDetails],
        typeRelationDetails: [RelationDetails],
        featuredTypeRelationsDetails: [RelationDetails],
        objectId: String,
        relationValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> ParsedRelations
}

final class RelationsBuilder: RelationsBuilderProtocol {
    
    @Injected(\.singleRelationBuilder)
    private var builder: any SingleRelationBuilderProtocol
    
    func parsedRelations(
        objectRelationDetails: [RelationDetails],
        typeRelationDetails: [RelationDetails],
        featuredTypeRelationsDetails: [RelationDetails],
        objectId: String,
        relationValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> ParsedRelations {
        guard let objectDetails = storage.get(id: objectId) else { return .empty }
        
        let objectRelations = buildRelations(
            relationDetails: objectRelationDetails,
            objectDetails: objectDetails,
            isFeatured: false,
            relationValuesIsLocked: relationValuesIsLocked,
            storage: storage
        )
        
        let deletedRelations = objectRelations.filter({ $0.isDeleted }) // TBD: take info from type as well
        
        let featuredRelations = buildRelations(
            relationDetails: featuredTypeRelationsDetails,
            objectDetails: objectDetails,
            isFeatured: true,
            relationValuesIsLocked: relationValuesIsLocked,
            hackGlobalName: true,
            storage: storage
        )
        
        let typeRelations = buildRelations(
            relationDetails: typeRelationDetails,
            objectDetails: objectDetails,
            isFeatured: false,
            relationValuesIsLocked: relationValuesIsLocked,
            storage: storage
        )
        
        let conflictedRelations = objectRelations.filter { !typeRelations.contains($0) && !featuredRelations.contains($0) }
        
        return ParsedRelations(
            featuredRelations: featuredRelations,
            sidebarRelations: typeRelations,
            conflictedRelations: conflictedRelations,
            deletedRelations: deletedRelations
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
