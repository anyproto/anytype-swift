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
        #warning("Check me")
        let filteredTags = searchService.searchRelationOptions(
            text: text,
            relationKey: relationKey,
            excludedObjectIds: selectedTagIds)?
            .map { RelationOption(details: $0) }
            .map { RelationValue.Tag.Option(option: $0) } ?? []
        #warning("Fix two maps ^^^")
//        guard text.isNotEmpty else {
//            return .success(availableTags)
//        }
//
//        let filteredTags: [RelationValue.Tag.Option] = availableTags.filter {
//            guard $0.text.isNotEmpty else { return false }
//
//            return $0.text.lowercased().contains(text.lowercased())
//        }
//
//        if filteredTags.isEmpty {
//            let isSearchedTagSelected = allTags.filter { tag in
//                selectedTagIds.contains { $0 == tag.id }
//            }
//                .contains { $0.text.lowercased() == text.lowercased() }
//
//            return isSearchedTagSelected ?
//                .failure(.alreadySelected(searchText: text)) :
//                .success(filteredTags)
//        }
        
        return .success(filteredTags)
    }
    
    func isCreateButtonAvailable(searchText: String, tags: [RelationValue.Tag.Option]) -> Bool {
        searchText.isNotEmpty && tags.isEmpty
    }
}
