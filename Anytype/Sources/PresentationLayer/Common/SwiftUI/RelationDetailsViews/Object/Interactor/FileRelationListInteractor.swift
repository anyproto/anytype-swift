import Services

@MainActor
final class FileRelationListInteractor: ObjectRelationListInteractorProtocol {
    
    let limitedObjectTypes: [ObjectType]
    
    private let spaceId: String
    private let searchService: SearchServiceProtocol
    
    init(spaceId: String, searchService: SearchServiceProtocol) {
        self.spaceId = spaceId
        self.limitedObjectTypes = []
        self.searchService = searchService
    }
    
    func searchOptions(text: String) async throws -> [ObjectRelationOption] {
        try await searchService.searchFiles(
            text: text,
            excludedFileIds: [],
            spaceId: spaceId
        ).map { ObjectRelationOption(objectDetails: $0) }
    }
}
