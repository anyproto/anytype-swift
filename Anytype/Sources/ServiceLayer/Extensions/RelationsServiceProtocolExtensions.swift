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
        var recommendedRelationsDetails = details.recommendedRelationsDetails
        recommendedRelationsDetails.insert(relation, at: 0)
        try await updateTypeRelations(
            typeId: details.id,
            recommendedRelations: recommendedRelationsDetails,
            recommendedFeaturedRelations: details.recommendedFeaturedRelationsDetails,
            recommendedHiddenRelations: details.recommendedHiddenRelationsDetails
        )
    }
    
    func addTypeFeaturedRecommendedRelation(details: ObjectDetails, relation: RelationDetails) async throws {
        var recommendedFeaturedRelationsDetails = details.recommendedFeaturedRelationsDetails
        recommendedFeaturedRelationsDetails.insert(relation, at: 0)
        try await updateTypeRelations(
            typeId: details.id,
            recommendedRelations: details.recommendedRelationsDetails,
            recommendedFeaturedRelations: recommendedFeaturedRelationsDetails,
            recommendedHiddenRelations: details.recommendedHiddenRelationsDetails
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
