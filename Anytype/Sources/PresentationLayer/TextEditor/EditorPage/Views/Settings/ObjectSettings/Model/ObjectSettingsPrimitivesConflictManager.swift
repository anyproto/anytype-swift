import Services


// Manages edje-cases of primitives project migration
protocol ObjectSettingsPrimitivesConflictManagerProtocol: Sendable {
    func haveLayoutConflicts(details: ObjectDetails) -> Bool
    func resolveConflicts(details: ObjectDetails) async throws
}

final class ObjectSettingsPrimitivesConflictManager: ObjectSettingsPrimitivesConflictManagerProtocol {
    private let objectTypeProvider: any ObjectTypeProviderProtocol = Container.shared.objectTypeProvider()
    private let relationDetailsStorage: any RelationDetailsStorageProtocol = Container.shared.relationDetailsStorage()
    private let relationsService: any RelationsServiceProtocol = Container.shared.relationsService()
    
    func haveLayoutConflicts(details: ObjectDetails) -> Bool {
        guard !details.isObjectType else { return false }
        
        let typeId = details.isTemplateType ? details.targetObjectType : details.type
        guard let type = try? objectTypeProvider.objectType(id: typeId) else { return false }
        let layoutsInObjectAndTypeAreDifferent = details.resolvedLayoutValue != type.recommendedLayout
        let layoutAlignInObjectAndTypeAreDifferent = details.layoutAlignValue != type.layoutAlign
        let layoutWidthInObjectAndTypeAreDifferent = details.layoutWidth != type.layoutWidth
        if layoutsInObjectAndTypeAreDifferent || layoutAlignInObjectAndTypeAreDifferent || layoutWidthInObjectAndTypeAreDifferent { return true }
        
        let typeFeaturedRelationKeys = details.objectType.recommendedFeaturedRelationsDetails
            .map(\.key)
            .filter { $0 != BundledRelationKey.description.rawValue } // Filter out description - currently we use object featured relation to store its visibility
        let objectFeaturedRelationKeys = relationDetailsStorage
            .relationsDetails(ids: details.featuredRelations, spaceId: details.spaceId)
            .map(\.key)
            .filter { $0 != BundledRelationKey.description.rawValue } // Filter out description - currently we use object featured relation to store its visibility
            
        let featuredRelationsInObjectAndTypeAreDifferent = typeFeaturedRelationKeys != objectFeaturedRelationKeys
        
        if objectFeaturedRelationKeys.isNotEmpty && featuredRelationsInObjectAndTypeAreDifferent { return true }
        
        return false
    }
    
    func resolveConflicts(details: ObjectDetails) async throws {
        // Remove legacy relations
        try await relationsService.removeRelation(objectId: details.id, relationKey: BundledRelationKey.layout.rawValue)
        try await relationsService.removeRelation(objectId: details.id, relationKey: BundledRelationKey.layoutAlign.rawValue)
        try await relationsService.removeRelation(objectId: details.id, relationKey: BundledRelationKey.layoutWidth.rawValue)
        
        // Remove all legacy relations except for description if present (description uses legacy mechanism to preserve its visibility)
        let featuredRelationIds = relationDetailsStorage
            .relationsDetails(ids: details.featuredRelations, spaceId: details.spaceId)
                .filter { $0.key == BundledRelationKey.description.rawValue }
                .map(\.id)
        try await relationsService.setFeaturedRelation(objectId: details.id, featuredRelationIds: featuredRelationIds)
    }
}

extension Container {
    var objectSettingsConflictManager: Factory<any ObjectSettingsPrimitivesConflictManagerProtocol> {
        self { ObjectSettingsPrimitivesConflictManager() }.shared
    }
}
