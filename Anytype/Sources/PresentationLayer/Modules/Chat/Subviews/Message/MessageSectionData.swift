import Foundation

struct MessageSectionData: Identifiable, Equatable, Hashable, ChatCollectionSection {
    let header: String
    let id: String
    let items: [MessageViewData]
}
