import Foundation

public extension Array where Element == URLQueryItem {
    func stringValue(key: String) -> String? {
        first(where: { $0.name == key })?.value
    }
    
    func intValue(key: String) -> Int? {
        guard let string = stringValue(key: key) else { return nil }
        return Int(string)
    }
}
