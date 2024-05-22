import Foundation

struct MailUrl {
    
    var to: String
    var subject: String
    var body: String
    
    var url: URL? {
        guard let string else { return nil }
        return URL(string: string)
    }
    
    var string: String? {
        guard let subjectQuery = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let bodyQuery = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        return "mailto:\(to)?subject=\(subjectQuery)&body=\(bodyQuery)"
    }
}
