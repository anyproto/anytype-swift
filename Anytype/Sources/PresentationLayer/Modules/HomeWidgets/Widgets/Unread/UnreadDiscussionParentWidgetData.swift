import Foundation

struct UnreadDiscussionParentWidgetData: Identifiable, Equatable {
    let id: String
    let spaceId: String
    let output: (any CommonWidgetModuleOutput)?

    static func == (lhs: UnreadDiscussionParentWidgetData, rhs: UnreadDiscussionParentWidgetData) -> Bool {
        lhs.id == rhs.id && lhs.spaceId == rhs.spaceId
    }
}
