import Foundation
import Services

struct UnreadDiscussionParentRowData: Identifiable, Equatable {
    let details: ObjectDetails
    let badge: ParentObjectUnreadBadge
    let lastMessageDate: Date?

    var id: String { details.id }
    var spaceId: String { details.spaceId }
    var name: String { details.pluralTitle }
    var icon: Icon? { details.objectIconImage }
}
