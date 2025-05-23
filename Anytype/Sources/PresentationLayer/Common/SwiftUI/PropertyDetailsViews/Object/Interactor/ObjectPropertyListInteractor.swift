import Services

@MainActor
final class ObjectPropertyListInteractor: ObjectPropertyListInteractorProtocol {
    
    let limitedObjectTypes: [ObjectType]
    
    private let spaceId: String
    
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    
    init(
        spaceId: String,
        limitedObjectTypes: [ObjectType]
    ) {
        self.spaceId = spaceId
        self.limitedObjectTypes = limitedObjectTypes
    }
    
    func searchOptions(text: String, limitObjectIds: [String]) async throws -> [ObjectPropertyOption] {
        try await searchService.search(text: text, spaceId: spaceId, limitObjectIds: limitObjectIds)
            .map { ObjectPropertyOption(objectDetails: $0) }
    }
    
    func searchOptions(text: String, excludeObjectIds: [String]) async throws -> [ObjectPropertyOption] {
        try await searchService.searchObjectsByTypes(
            text: text,
            typeIds: limitedObjectTypes.map { $0.id },
            excludedObjectIds: excludeObjectIds,
            spaceId: spaceId
        ).map { ObjectPropertyOption(objectDetails: $0) }
    }
}
