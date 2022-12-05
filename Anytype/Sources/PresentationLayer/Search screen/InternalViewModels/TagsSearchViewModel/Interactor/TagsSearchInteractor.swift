import Foundation
import BlocksModels

final class TagsSearchInteractor {
    
    private let allTags: [Relation.Tag.Option] = []
    private let relationKey: String
    private let selectedTagIds: [String]
    private let isPreselectModeAvailable: Bool
    private let searchService = ServiceLocator.shared.searchService()
    
    init(
        relationKey: String,
        selectedTagIds: [String],
        isPreselectModeAvailable: Bool = false
    ) {
        self.relationKey = relationKey
        self.selectedTagIds = selectedTagIds
        self.isPreselectModeAvailable = isPreselectModeAvailable
    }
    
}

extension TagsSearchInteractor {
    
    func search(text: String) -> Result<[Relation.Tag.Option], NewSearchError> {
        let filteredTags = searchService.searchRelationOptions(
            text: text,
            relationKey: relationKey,
            excludedObjectIds: selectedTagIds)?
            .map { Relation.Tag.Option(option: $0) } ?? []

        return .success(filteredTags)
    }
    
    func isCreateButtonAvailable(searchText: String, tags: [Relation.Tag.Option]) -> Bool {
        searchText.isNotEmpty && tags.isEmpty
    }
}
