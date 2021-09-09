import BlocksModels

struct MentionsParser {
    
    func parseMentions(from searchResults: [SearchResult]) -> [MentionObject] {
        searchResults.map { mention(from: $0) }
    }
    
    func mention(from searchResult: SearchResult) -> MentionObject {
        MentionObject(
            id: searchResult.id,
            icon: mentionIcon(from: searchResult),
            objectIcon: objectIcon(result: searchResult),
            name: mentionName(from: searchResult),
            description: searchResult.description,
            type: searchResult.type
        )
    }
    
    private func objectIcon(result: SearchResult) -> ObjectIconImage {
        if let objectIcon = result.objectIconImage {
            return objectIcon
        }
        
        return .placeholder(mentionName(from: result).first)
    }
    
    private func mentionName(from result: SearchResult) -> String {
        let name = result.name ?? ""
        return name.isEmpty ? "Untitled".localized : name
    }
    
    private func mentionIcon(from details: DetailsDataProtocol) -> MentionIcon? {
        if let objectIcon = details.icon {
            return .objectIcon(objectIcon)
        }
        
        guard case .todo = details.layout else { return nil }
        
        return .checkmark(details.done ?? false)
    }
}
