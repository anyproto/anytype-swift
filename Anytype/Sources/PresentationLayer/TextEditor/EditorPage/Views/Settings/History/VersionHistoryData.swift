import Foundation

struct VersionHistoryData: Identifiable, Hashable {
    let objectId: String
    let spaceId: String
    let isListType: Bool
    let canRestore: Bool
    
    var id: Int { hashValue }
}
