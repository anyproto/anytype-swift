import Foundation

final class TagsSearchInteractor {
    
    private let allTags: [Relation.Tag.Option]
    private let selectedTagIds: [String]
    
    init(allTags: [Relation.Tag.Option], selectedTagIds: [String]) {
        self.allTags = allTags
        self.selectedTagIds = selectedTagIds
    }
    
}

extension TagsSearchInteractor {
    
    func search(text: String) -> Result<[Relation.Tag.Option], NewSearchError> {
        guard text.isNotEmpty else {
            return .success(availableTags)
        }

        let filteredTags: [Relation.Tag.Option] = availableTags.filter {
            guard $0.text.isNotEmpty else { return false }
            
            return $0.text.lowercased().contains(text.lowercased())
        }
        
        if filteredTags.isEmpty {
            let isSearchedTagSelected = allTags.filter { tag in
                selectedTagIds.contains { $0 == tag.id }
            }
                .contains { $0.text.lowercased() == text.lowercased() }
            
            return isSearchedTagSelected ?
                .failure(.alreadySelected(searchText: text)) :
                .success(filteredTags)
        }
        
        return .success(filteredTags)
    }
    
    func isCreateButtonAvailable(searchText: String) -> Bool {
        searchText.isNotEmpty && !allTags.contains { $0.text.lowercased() == searchText.lowercased() }
    }
    
}

private extension TagsSearchInteractor {
    
    var availableTags: [Relation.Tag.Option] {
        guard selectedTagIds.isNotEmpty else { return allTags }
        
        return allTags.filter { tag in
            !selectedTagIds.contains { $0 == tag.id }
        }
    }
    
}
