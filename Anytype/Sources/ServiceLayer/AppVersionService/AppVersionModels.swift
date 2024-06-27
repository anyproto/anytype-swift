import Foundation

struct LoolupResponse: Codable {
    let results: [LookupResult]
}

struct LookupResult: Codable {
    let version: String
}
