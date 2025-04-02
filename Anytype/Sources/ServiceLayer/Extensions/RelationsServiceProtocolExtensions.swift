import Services

extension RelationsServiceProtocol {
    func updateTypeRelations(
        typeId: String,
        recommendedRelations: [RelationDetails],
        recommendedFeaturedRelations: [RelationDetails],
        recommendedHiddenRelations: [RelationDetails]
    ) async throws {
        try await updateTypeRelations(
            typeId: typeId,
            dataviewId: SetConstants.dataviewBlockId,
            recommendedRelations: recommendedRelations,
            recommendedFeaturedRelations: recommendedFeaturedRelations,
            recommendedHiddenRelations: recommendedHiddenRelations
        )
    }
    
    func addTypeRecommendedRelation(details: ObjectDetails, relation: RelationDetails) async throws {
        try await addTypeRecommendedRelation(type: ObjectType(details: details), relation: relation)
    }
    
    func addTypeRecommendedRelation(type: ObjectType, relation: RelationDetails) async throws {
        var recommendedRelationsDetails = type.recommendedRelationsDetails
        recommendedRelationsDetails.insert(relation, at: 0)
        try await updateTypeRelations(
            typeId: type.id,
            recommendedRelations: recommendedRelationsDetails,
            recommendedFeaturedRelations: type.recommendedFeaturedRelationsDetails,
            recommendedHiddenRelations: type.recommendedHiddenRelationsDetails
        )
    }
    
    func addTypeFeaturedRecommendedRelation(details: ObjectDetails, relation: RelationDetails) async throws {
        try await addTypeFeaturedRecommendedRelation(type: ObjectType(details: details), relation: relation)
    }
    
    func addTypeFeaturedRecommendedRelation(type: ObjectType, relation: RelationDetails) async throws {
        var recommendedFeaturedRelationsDetails = type.recommendedFeaturedRelationsDetails
        recommendedFeaturedRelationsDetails.insert(relation, at: 0)
        try await updateTypeRelations(
            typeId: type.id,
            recommendedRelations: type.recommendedRelationsDetails,
            recommendedFeaturedRelations: recommendedFeaturedRelationsDetails,
            recommendedHiddenRelations: type.recommendedHiddenRelationsDetails
        )
    }
        
    func deleteTypeRelation(details: ObjectDetails, relationId: String) async throws {
        let recommendedRelations = details.recommendedRelationsDetails.filter({ relationId != $0.id })
        let recommendedFeaturedRelations = details.recommendedFeaturedRelationsDetails.filter({ relationId != $0.id })
        let recommendedHiddenRelations = details.recommendedHiddenRelationsDetails.filter({ relationId != $0.id })
        try await updateTypeRelations(
            typeId: details.id,
            recommendedRelations: recommendedRelations,
            recommendedFeaturedRelations: recommendedFeaturedRelations,
            recommendedHiddenRelations: recommendedHiddenRelations
        )
    }
}
