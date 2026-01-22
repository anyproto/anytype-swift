import Foundation

struct UnreadChatWidgetData: Identifiable, Equatable {
    let id: String
    let spaceId: String
    let output: (any CommonWidgetModuleOutput)?

    static func == (lhs: UnreadChatWidgetData, rhs: UnreadChatWidgetData) -> Bool {
        lhs.id == rhs.id && lhs.spaceId == rhs.spaceId
    }
}
