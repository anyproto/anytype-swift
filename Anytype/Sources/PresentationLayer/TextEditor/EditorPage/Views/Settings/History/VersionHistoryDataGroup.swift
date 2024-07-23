import Foundation
import Services

struct VersionHistoryDataGroup: Identifiable, Hashable {
    let title: String
    let icons: [ObjectIcon]
    let versions: [[VersionHistoryItem]]
    
    var id: Int { hashValue }
}

struct VersionHistoryItem: Identifiable, Hashable {
    let id: String
    let time: String
    let author: String
    let icon: ObjectIcon?
}
