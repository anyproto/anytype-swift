import Foundation

struct VersionHistoryData: Identifiable, Hashable {
    let objectId: String
    let spaceId: String
    let isListType: Bool
    
    var id: Int { hashValue }
}
