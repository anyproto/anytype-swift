import Foundation
import Services

struct VersionHistoryItem: Identifiable, Hashable {
    let id: String
    let time: String
    let author: String
    let icon: ObjectIcon?
}
