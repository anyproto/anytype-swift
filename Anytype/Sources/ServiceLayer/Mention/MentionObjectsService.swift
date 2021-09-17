
final class MentionObjectsService {
    
    var filterString = ""
    private let searchService: SearchServiceProtocol
    
    init(searchService: SearchServiceProtocol) {
        self.searchService = searchService
    }
    
    func loadMentions(completion: @escaping ([MentionObject]) -> Void) {
        searchService.search(text: filterString) { searchResults in
            completion(
                searchResults.map { MentionObject(searchResult: $0) }
            )
        }
    }
}
