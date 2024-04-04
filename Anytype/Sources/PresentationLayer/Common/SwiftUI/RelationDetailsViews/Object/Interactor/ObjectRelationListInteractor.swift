import Services

@MainActor
final class ObjectRelationListInteractor: ObjectRelationListInteractorProtocol {
    
    let limitedObjectTypes: [ObjectType]
    
    private let spaceId: String
    
    @Injected(\.searchService)
    private var searchService: SearchServiceProtocol
    
    init(
        spaceId: String,
        limitedObjectTypes: [ObjectType]
    ) {
        self.spaceId = spaceId
        self.limitedObjectTypes = limitedObjectTypes
    }
    
    func searchOptions(text: String, limitObjectIds: [String]) async throws -> [ObjectRelationOption] {
        try await searchService.search(text: text, limitObjectIds: limitObjectIds, spaceId: spaceId)
            .map { ObjectRelationOption(objectDetails: $0) }
    }
    
    func searchOptions(text: String, excludeObjectIds: [String]) async throws -> [ObjectRelationOption] {
        try await searchService.searchObjectsByTypes(
            text: text,
            typeIds: limitedObjectTypes.map { $0.id },
            excludedObjectIds: excludeObjectIds,
            spaceId: spaceId
        ).map { ObjectRelationOption(objectDetails: $0) }
    }
}
