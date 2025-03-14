import Foundation

struct MessageSectionData: Identifiable, Equatable, Hashable, ChatCollectionSection {
    var header: String
    var id: Int
    var items: [MessageSectionItem]
}
