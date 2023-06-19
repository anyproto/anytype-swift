import Foundation

extension Data {
    
    func parseMessages() -> String {
        if let jsonObject = try? JSONSerialization.jsonObject(with: self) as? [String: Any],
           let messages = jsonObject["messages"] as? [[String: Any]] {
            return messages.flatMap { $0.keys }.sorted().joined(separator: ",")
        } else {
            return ""
        }
    }
}
