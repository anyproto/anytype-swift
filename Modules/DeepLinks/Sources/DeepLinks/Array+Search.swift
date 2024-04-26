import Foundation

extension Array where Element == URLQueryItem {
    func itemValue(key: String) -> String? {
        first(where: { $0.name == key })?.value
    }
}
