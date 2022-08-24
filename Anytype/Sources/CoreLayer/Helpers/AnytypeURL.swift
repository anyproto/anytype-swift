import Foundation

struct AnytypeURL {
    
    private let source: URL
    
    init?(string: String) {
        guard let encodedString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedString) else { return nil }
        self.source = url
    }
    
    init(url: URL) {
        self.source = url
    }
    
    var absoluteString: String {
        return source.absoluteString.removingPercentEncoding ?? source.absoluteString
    }
    
    var url: URL {
        return source
    }
}
