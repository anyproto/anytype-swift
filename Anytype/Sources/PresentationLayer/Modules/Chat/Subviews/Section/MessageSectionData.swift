import Foundation
import StoredHashMacro

@StoredHash
struct MessageSectionData: Identifiable, Equatable, Hashable, ChatCollectionSection {
    var header: String
    var id: Int
    var items: [MessageSectionItem]
}
