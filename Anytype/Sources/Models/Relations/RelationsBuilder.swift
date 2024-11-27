import Foundation
import Services
import SwiftProtobuf
import UIKit
import AnytypeCore

protocol RelationsBuilderProtocol: AnyObject {
    func parsedRelations(
        objectRelations: [RelationDetails],
        typeRelations: [RelationDetails],
        objectId: String,
        relationValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> ParsedRelations
}

final class RelationsBuilder: RelationsBuilderProtocol {
    
    @Injected(\.singleRelationBuilder)
    private var builder: any SingleRelationBuilderProtocol
    
    // MARK: - Internal functions
    
    func parsedRelations(
        objectRelations: [RelationDetails],
        typeRelations: [RelationDetails],
        objectId: String,
        relationValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> ParsedRelations {
        guard let objectDetails = storage.get(id: objectId) else {
            return .empty
        }
        
        var featuredRelations: [Relation] = []
        var deletedRelations: [Relation] = []
        var otherRelations: [Relation] = []
        
        
        hackGlobalNameValue(
            objectRelations: objectRelations,
            objectDetails: objectDetails,
            relationValuesIsLocked: relationValuesIsLocked,
            storage: storage
        )
        .flatMap { featuredRelations.append($0) }
        
        
        objectRelations.forEach { relationDetails in
            guard !relationDetails.isHidden else { return }
            guard relationDetails.key != BundledRelationKey.globalName.rawValue && relationDetails.key != BundledRelationKey.identity.rawValue else {
                return // see hackGlobalNameValue
            }
            
            let value = builder.relation(
                relationDetails: relationDetails,
                details: objectDetails,
                relationValuesIsLocked: relationValuesIsLocked,
                storage: storage
            )
            
            guard let value else { return }
            
            if value.isFeatured {
                featuredRelations.append(value)
            } else if value.isDeleted {
                deletedRelations.append(value)
            } else {
                otherRelations.append(value)
            }
        }
        
        let typeRelations: [Relation] = typeRelations.compactMap { relationDetails in
            guard !relationDetails.isHidden else { return nil }
            return builder.relation(
                relationDetails: relationDetails,
                details: objectDetails,
                relationValuesIsLocked: relationValuesIsLocked,
                storage: storage
            )
        }
        
        return ParsedRelations(
            featuredRelations: featuredRelations,
            deletedRelations: deletedRelations,
            typeRelations: typeRelations,
            otherRelations: otherRelations
        )
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
            relationValuesIsLocked: relationValuesIsLocked,
            storage: storage
        ), globaName.hasValue { return globaName }
        
        if let identity = relationForKey(
            key: BundledRelationKey.identity.rawValue,
            objectRelations: objectRelations,
            objectDetails: objectDetails,
            relationValuesIsLocked: relationValuesIsLocked,
            storage: storage
        ), identity.hasValue { return identity }
        
        return nil
    }
    
    private func relationForKey(
        key: String,
        objectRelations: [RelationDetails],
        objectDetails: ObjectDetails,
        relationValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Relation? {
        guard let details = objectRelations.first(where: { $0.key == key }) else {
            return nil
        }
        
        return builder.relation(
            relationDetails: details,
            details: objectDetails,
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
