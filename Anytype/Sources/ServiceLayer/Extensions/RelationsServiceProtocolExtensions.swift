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
}
