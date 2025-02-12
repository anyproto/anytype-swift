import Foundation
import Services

@MainActor
final class TagsSearchInteractor {
    
    private let spaceId: String
    private let relationKey: String
    private let selectedTagIds: [String]
    private let isPreselectModeAvailable: Bool
    
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    
    init(
        spaceId: String,
        relationKey: String,
        selectedTagIds: [String],
        isPreselectModeAvailable: Bool = false
    ) {
        self.spaceId = spaceId
        self.relationKey = relationKey
        self.selectedTagIds = selectedTagIds
        self.isPreselectModeAvailable = isPreselectModeAvailable
    }
    
}

extension TagsSearchInteractor {
    
    func search(text: String) async throws -> [Relation.Tag.Option] {
        try await searchService.searchRelationOptions(
            text: text,
            relationKey: relationKey,
            excludedObjectIds: selectedTagIds,
            spaceId: spaceId
        ).map { Relation.Tag.Option(option: $0) }
    }
    
    func isCreateButtonAvailable(searchText: String, tags: [Relation.Tag.Option]) -> Bool {
        searchText.isNotEmpty && tags.isEmpty
    }
}
