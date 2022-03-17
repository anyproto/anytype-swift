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
    
    func search(text: String, onCompletion: ([Relation.Tag.Option]) -> ()) {
        guard text.isNotEmpty else {
            onCompletion(availableTags)
            return
        }

        let filteredTags: [Relation.Tag.Option] = availableTags.filter {
            guard $0.text.isNotEmpty else { return false }
            
            return $0.text.lowercased().contains(text.lowercased())
        }
        
        onCompletion(filteredTags)
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
