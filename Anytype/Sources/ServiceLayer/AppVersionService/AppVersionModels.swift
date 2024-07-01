import Foundation

struct LookupResponse: Codable {
    let results: [LookupResult]
}

struct LookupResult: Codable {
    let version: String
}
