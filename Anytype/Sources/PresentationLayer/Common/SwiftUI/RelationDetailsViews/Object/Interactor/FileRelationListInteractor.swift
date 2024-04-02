import Services

@MainActor
final class FileRelationListInteractor: ObjectRelationListInteractorProtocol {
    
    let limitedObjectTypes: [ObjectType]
    
    private let spaceId: String
    
    @Injected(\.searchService)
    private var searchService: SearchServiceProtocol
    
    init(spaceId: String) {
        self.spaceId = spaceId
        self.limitedObjectTypes = []
    }
    
    func searchOptions(text: String, limitObjectIds: [String]) async throws -> [ObjectRelationOption] {
        try await searchService.search(text: text, limitObjectIds: limitObjectIds)
            .map { ObjectRelationOption(objectDetails: $0) }
    }
    
    func searchOptions(text: String, excludeObjectIds: [String]) async throws -> [ObjectRelationOption] {
        try await searchService.searchFiles(
            text: text,
            excludedFileIds: excludeObjectIds,
            spaceId: spaceId
        ).map { ObjectRelationOption(objectDetails: $0) }
    }
}
