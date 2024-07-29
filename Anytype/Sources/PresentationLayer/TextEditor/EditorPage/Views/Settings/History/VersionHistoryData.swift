import Foundation

struct VersionHistoryData: Identifiable, Hashable {
    let objectId: String
    let spaceId: String
    
    var id: Int { hashValue }
}
