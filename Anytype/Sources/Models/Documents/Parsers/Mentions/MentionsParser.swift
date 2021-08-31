import BlocksModels

struct MentionsParser {
    
    func parseMentions(from searchResults: [SearchResult]) -> [MentionObject] {
        searchResults.map { mention(from: $0) }
    }
    
    func mention(from searchResult: SearchResult) -> MentionObject {
        MentionObject(
            id: searchResult.id,
            icon: mentionIcon(from: searchResult),
            name: searchResult.name,
            description: searchResult.description,
            type: searchResult.type
        )
    }
    
    private func mentionIcon(from details: DetailsDataProtocol) -> MentionIcon? {
        if let objectIcon = details.icon {
            return .objectIcon(objectIcon)
        }
        
        guard case .todo = details.layout else { return nil }
        
        return .checkmark(details.done ?? false)
    }
}
