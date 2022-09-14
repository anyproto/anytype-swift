import Foundation
import BlocksModels

final class TagsSearchInteractor {
    
    private let allTags: [RelationValue.Tag.Option] = []
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
    
    func search(text: String) -> Result<[RelationValue.Tag.Option], NewSearchError> {
        let filteredTags = searchService.searchRelationOptions(
            text: text,
            relationKey: relationKey,
            excludedObjectIds: selectedTagIds)?
            .map { RelationValue.Tag.Option(option: $0) } ?? []

        return .success(filteredTags)
    }
    
    func isCreateButtonAvailable(searchText: String, tags: [RelationValue.Tag.Option]) -> Bool {
        searchText.isNotEmpty && tags.isEmpty
    }
}
