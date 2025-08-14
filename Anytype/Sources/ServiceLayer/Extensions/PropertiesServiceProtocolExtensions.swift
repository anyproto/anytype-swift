import Services

extension PropertiesServiceProtocol {
    func updateTypeProperties(
        typeId: String,
        recommendedProperties: [PropertyDetails],
        recommendedFeaturedProperties: [PropertyDetails],
        recommendedHiddenProperties: [PropertyDetails]
    ) async throws {
        try await updateTypeProperties(
            typeId: typeId,
            dataviewId: SetConstants.dataviewBlockId,
            recommendedProperties: recommendedProperties,
            recommendedFeaturedProperties: recommendedFeaturedProperties,
            recommendedHiddenProperties: recommendedHiddenProperties
        )
    }
    
    func addTypeRecommendedProperty(details: ObjectDetails, property: PropertyDetails) async throws {
        try await addTypeRecommendedProperty(type: ObjectType(details: details), property: property)
    }
    
    func addTypeRecommendedProperty(type: ObjectType, property: PropertyDetails) async throws {
        var recommendedPropertiesDetails = type.recommendedRelationsDetails
        recommendedPropertiesDetails.insert(property, at: 0)
        try await updateTypeProperties(
            typeId: type.id,
            recommendedProperties: recommendedPropertiesDetails,
            recommendedFeaturedProperties: type.recommendedFeaturedRelationsDetails,
            recommendedHiddenProperties: type.recommendedHiddenRelationsDetails
        )
    }
    
    func addTypeFeaturedRecommendedProperty(details: ObjectDetails, property: PropertyDetails) async throws {
        try await addTypeFeaturedRecommendedProperty(type: ObjectType(details: details), property: property)
    }
    
    func addTypeFeaturedRecommendedProperty(type: ObjectType, property: PropertyDetails) async throws {
        var recommendedFeaturedPropertiesDetails = type.recommendedFeaturedRelationsDetails
        recommendedFeaturedPropertiesDetails.insert(property, at: 0)
        try await updateTypeProperties(
            typeId: type.id,
            recommendedProperties: type.recommendedRelationsDetails,
            recommendedFeaturedProperties: recommendedFeaturedPropertiesDetails,
            recommendedHiddenProperties: type.recommendedHiddenRelationsDetails
        )
    }
        
    func removeTypeProperty(details: ObjectDetails, propertyId: String) async throws {
        let recommendedProperties = details.recommendedRelationsDetails.filter({ propertyId != $0.id })
        let recommendedFeaturedProperties = details.recommendedFeaturedRelationsDetails.filter({ propertyId != $0.id })
        let recommendedHiddenProperties = details.recommendedHiddenRelationsDetails.filter({ propertyId != $0.id })
        try await updateTypeProperties(
            typeId: details.id,
            recommendedProperties: recommendedProperties,
            recommendedFeaturedProperties: recommendedFeaturedProperties,
            recommendedHiddenProperties: recommendedHiddenProperties
        )
    }
}
