import Services

@MainActor
final class FilePropertyListInteractor: ObjectPropertyListInteractorProtocol {
    
    let limitedObjectTypes: [ObjectType]
    
    private let spaceId: String
    
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    
    init(spaceId: String) {
        self.spaceId = spaceId
        self.limitedObjectTypes = []
    }
    
    func searchOptions(text: String, limitObjectIds: [String]) async throws -> [ObjectPropertyOption] {
        try await searchService.search(text: text, spaceId: spaceId, limitObjectIds: limitObjectIds)
            .map { ObjectPropertyOption(objectDetails: $0) }
    }
    
    func searchOptions(text: String, excludeObjectIds: [String]) async throws -> [ObjectPropertyOption] {
        try await searchService.searchFiles(
            text: text,
            excludedFileIds: excludeObjectIds,
            spaceId: spaceId
        ).map { ObjectPropertyOption(objectDetails: $0) }
    }
}
