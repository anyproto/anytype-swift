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
    
    func searchOptions(text: String) async throws -> [ObjectRelationOption] {
        try await searchService.searchFiles(
            text: text,
            excludedFileIds: [],
            spaceId: spaceId
        ).map { ObjectRelationOption(objectDetails: $0) }
    }
}
