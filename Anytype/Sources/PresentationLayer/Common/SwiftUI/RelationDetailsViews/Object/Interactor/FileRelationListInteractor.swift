import Services

@MainActor
final class FileRelationListInteractor: ObjectRelationListInteractorProtocol {
    
    let limitedObjectTypes: [ObjectType]
    let canDuplicateObject: Bool
    
    private let spaceId: String
    private let searchService: SearchServiceProtocol
    
    init(spaceId: String, searchService: SearchServiceProtocol) {
        self.spaceId = spaceId
        self.limitedObjectTypes = []
        self.canDuplicateObject = false
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
