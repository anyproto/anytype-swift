import Services

@MainActor
final class ObjectRelationListInteractor: ObjectRelationListInteractorProtocol {
    
    let limitedObjectTypes: [ObjectType]
    
    private let spaceId: String
    private let searchService: SearchServiceProtocol
    
    init(
        spaceId: String,
        limitedObjectTypes: [String],
        objectTypeProvider: ObjectTypeProviderProtocol,
        searchService: SearchServiceProtocol
    ) {
        self.spaceId = spaceId
        self.limitedObjectTypes = limitedObjectTypes.compactMap { id in
            objectTypeProvider.objectTypes.first { $0.id == id }
        }
        self.searchService = searchService
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
