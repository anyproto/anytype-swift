import Foundation
import Services

final class TagsSearchInteractor {
    
    private let relationKey: String
    private let selectedTagIds: [String]
    private let isPreselectModeAvailable: Bool
    private let searchService: SearchServiceProtocol
    
    init(
        relationKey: String,
        selectedTagIds: [String],
        isPreselectModeAvailable: Bool = false,
        searchService: SearchServiceProtocol
    ) {
        self.relationKey = relationKey
        self.selectedTagIds = selectedTagIds
        self.isPreselectModeAvailable = isPreselectModeAvailable
        self.searchService = searchService
    }
    
}

extension TagsSearchInteractor {
    
    func search(text: String) async throws -> [Relation.Tag.Option] {
        try await searchService.searchRelationOptions(
            text: text,
            relationKey: relationKey,
            excludedObjectIds: selectedTagIds)
            .map { Relation.Tag.Option(option: $0) }
    }
    
    func isCreateButtonAvailable(searchText: String, tags: [Relation.Tag.Option]) -> Bool {
        searchText.isNotEmpty && tags.isEmpty
    }
}
