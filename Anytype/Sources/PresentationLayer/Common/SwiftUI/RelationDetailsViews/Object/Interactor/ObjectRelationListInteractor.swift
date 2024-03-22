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
    
    func searchOptions(text: String) async throws -> [ObjectRelationOption] {
        try await searchService.searchObjectsByTypes(
            text: text,
            typeIds: limitedObjectTypes.map { $0.id },
            excludedObjectIds: [],
            spaceId: spaceId
        ).map { ObjectRelationOption(objectDetails: $0) }
    }
}
