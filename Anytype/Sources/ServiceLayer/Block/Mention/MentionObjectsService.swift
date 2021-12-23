final class MentionObjectsService {
    
    var filterString = ""
    private let searchService: SearchServiceProtocol
    
    init(searchService: SearchServiceProtocol) {
        self.searchService = searchService
    }
    
    func loadMentions() -> [MentionObject]? {
        return searchService.search(text: filterString)?
            .map { MentionObject(details: $0) }
    }
}
