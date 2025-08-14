import Foundation
import StoredHashMacro

@StoredHash
struct MessageSectionData: Identifiable, Equatable, Hashable, ChatCollectionSection {
    var header: String {
        didSet { updateHash() }
    }
    var id: Int {
        didSet { updateHash() }
    }
    var items: [MessageSectionItem] {
        didSet { updateHash() }
    }
}
