
final class MentionObjectsService {
    
    var filterString = ""
    private let searchService: SearchServiceProtocol
    private let parser: MentionsParser
    
    init(
        searchService: SearchServiceProtocol,
        parser: MentionsParser = MentionsParser()
    ) {
        self.searchService = searchService
        self.parser = parser
    }
    
    func loadMentions(completion: @escaping ([MentionObject]) -> Void) {
        searchService.search(text: filterString) { [weak self] searchResults in
            completion(self?.parser.parseMentions(from: searchResults) ?? [])
        }
    }
}
