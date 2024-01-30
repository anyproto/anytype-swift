import Services
import AnytypeCore


final class ObjectTypeSearchInteractor {
    private let spaceId: String
    private let searchService: SearchServiceProtocol
    
    init(spaceId: String, searchService: SearchServiceProtocol) {
        self.spaceId = spaceId
        self.searchService = searchService
    }
    
    func search(text: String) async -> [ObjectType] {
        do {
            return try await searchService.searchObjectTypes(
                text: text,
                filteringTypeId: nil, //excludedObjectTypeId,
                shouldIncludeSets: true, //showSetAndCollection,
                shouldIncludeCollections: true,// showSetAndCollection,
                shouldIncludeBookmark: true, //showBookmark,
                spaceId: spaceId
            )
            .map { ObjectType(details: $0) }
        } catch let error {
            anytypeAssertionFailure(
                "Error in searchObjectTypes",
                info: ["error": error.localizedDescription]
            )
            return []
        }
    }
}
