import Foundation
import Services
import SwiftProtobuf
import UIKit
import AnytypeCore

protocol PropertiesBuilderProtocol: AnyObject {
    func parsedProperties(
        objectProperties: [RelationDetails],
        objectFeaturedProperties: [RelationDetails],
        recommendedProperties: [RelationDetails],
        recommendedFeaturedProperties: [RelationDetails],
        recommendedHiddenProperties: [RelationDetails],
        objectId: String,
        propertyValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> ParsedProperties
}

final class PropertiesBuilder: PropertiesBuilderProtocol {
    
    @Injected(\.singlePropertyBuilder)
    private var builder: any SinglePropertyBuilderProtocol
    
    func parsedProperties(
        objectProperties: [RelationDetails],
        objectFeaturedProperties: [RelationDetails],
        recommendedProperties: [RelationDetails],
        recommendedFeaturedProperties: [RelationDetails],
        recommendedHiddenProperties: [RelationDetails],
        objectId: String,
        propertyValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> ParsedProperties {
        guard let objectDetails = storage.get(id: objectId) else { return .empty }
        
        let systemProperties = buildSystemProperties(relationDetails: objectProperties, objectDetails: objectDetails, storage: storage)
        
        let objectProperties = buildProperties(
            relationDetails: objectProperties,
            objectDetails: objectDetails,
            isFeatured: false,
            propertyValuesIsLocked: propertyValuesIsLocked,
            storage: storage
        )
        
        let legacyFeaturedProperties = buildProperties(
            relationDetails: objectFeaturedProperties,
            objectDetails: objectDetails,
            isFeatured: true,
            propertyValuesIsLocked: propertyValuesIsLocked,
            hackGlobalName: true,
            storage: storage
        ).filter { !recommendedHiddenProperties.map(\.id).contains($0.id) }
        
        let featuredProperties = buildProperties(
            relationDetails: recommendedFeaturedProperties,
            objectDetails: objectDetails,
            isFeatured: true,
            propertyValuesIsLocked: propertyValuesIsLocked,
            hackGlobalName: true,
            storage: storage
        ).filter { !recommendedHiddenProperties.map(\.id).contains($0.id) }
        
        let sidebarProperties = buildProperties(
            relationDetails: recommendedProperties,
            objectDetails: objectDetails,
            isFeatured: false,
            propertyValuesIsLocked: propertyValuesIsLocked,
            storage: storage
        ).filter { !recommendedHiddenProperties.map(\.id).contains($0.id) }
        
        let hiddenProperties = buildProperties(
            relationDetails: recommendedHiddenProperties,
            objectDetails: objectDetails,
            isFeatured: false,
            propertyValuesIsLocked: propertyValuesIsLocked,
            storage: storage
        )
        
        let allConflictedProperties = objectProperties
            .filter {
                !sidebarProperties.map(\.id).contains($0.id) &&
                !featuredProperties.map(\.id).contains($0.id) &&
                !hiddenProperties.map(\.id).contains($0.id)
            }
        
        let deletedProperties = allConflictedProperties.filter { $0.isDeleted }
        let conflictedProperties = allConflictedProperties.filter { !$0.isDeleted }
        
        return ParsedProperties(
            featuredProperties: featuredProperties,
            sidebarProperties: sidebarProperties,
            hiddenProperties: hiddenProperties,
            conflictedProperties: conflictedProperties,
            deletedProperties: deletedProperties,
            systemProperties: systemProperties,
            legacyFeaturedProperties: legacyFeaturedProperties
        )
    }
    
    private func buildProperties(
        relationDetails: [RelationDetails],
        objectDetails: ObjectDetails,
        isFeatured: Bool,
        propertyValuesIsLocked: Bool,
        hackGlobalName: Bool = false,
        storage: ObjectDetailsStorage
    ) -> [Relation] {
        var properties: [Relation] = relationDetails.compactMap { property in
            guard isPropertyCanBeAddedToList(property) else {
                return nil
            }
            return builder.property(
                relationDetails: property,
                details: objectDetails,
                isFeatured: isFeatured,
                propertyValuesIsLocked: propertyValuesIsLocked,
                storage: storage
            )
        }
        
        if hackGlobalName {
            hackGlobalNameValue(
                objectProperties: relationDetails,
                objectDetails: objectDetails,
                propertyValuesIsLocked: propertyValuesIsLocked,
                storage: storage
            )
            .flatMap { properties.append($0) }
        }

        return properties
    }
    
    private func buildSystemProperties(
        relationDetails: [RelationDetails],
        objectDetails: ObjectDetails,
        storage: ObjectDetailsStorage
    ) -> [Relation] {
        return relationDetails.compactMap { property in
            guard BundledPropertyKey.systemKeys.map(\.rawValue).contains(property.key) else {
                return nil
            }
            return builder.property(
                relationDetails: property,
                details: objectDetails,
                isFeatured: false,
                propertyValuesIsLocked: true,
                storage: storage
            )
        }
    }
    
    private func isPropertyCanBeAddedToList(_ property: RelationDetails) -> Bool {
        guard !property.isHidden else { return false }
        
        // We are filtering out description from the list of relations
        guard property.key != BundledPropertyKey.description.rawValue else { return false }
        
        // See hackGlobalNameValue
        guard property.key != BundledPropertyKey.globalName.rawValue && property.key != BundledPropertyKey.identity.rawValue else {
            return false
        }
        
        return true
    }
    
    //fallback to identiy if globalName is empty
    private func hackGlobalNameValue(
        objectProperties: [RelationDetails],
        objectDetails: ObjectDetails,
        propertyValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Relation? {
        if let globaName = propertyForKey(
            key: BundledPropertyKey.globalName.rawValue,
            objectProperties: objectProperties,
            objectDetails: objectDetails,
            isFeatured: true,
            propertyValuesIsLocked: propertyValuesIsLocked,
            storage: storage
        ), globaName.hasValue { return globaName }
        
        if let identity = propertyForKey(
            key: BundledPropertyKey.identity.rawValue,
            objectProperties: objectProperties,
            objectDetails: objectDetails,
            isFeatured: true,
            propertyValuesIsLocked: propertyValuesIsLocked,
            storage: storage
        ), identity.hasValue { return identity }
        
        return nil
    }
    
    private func propertyForKey(
        key: String,
        objectProperties: [RelationDetails],
        objectDetails: ObjectDetails,
        isFeatured: Bool,
        propertyValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Relation? {
        guard let details = objectProperties.first(where: { $0.key == key }) else {
            return nil
        }
        
        return builder.property(
            relationDetails: details,
            details: objectDetails,
            isFeatured: isFeatured,
            propertyValuesIsLocked: propertyValuesIsLocked,
            storage: storage
        )
    }
}

extension Container {
    var propertiesBuilder: Factory<any PropertiesBuilderProtocol> {
        self { PropertiesBuilder() }.shared
    }
}
