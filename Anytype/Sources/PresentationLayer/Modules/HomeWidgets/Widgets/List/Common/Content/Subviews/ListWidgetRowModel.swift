import Foundation

struct ListWidgetRowModel: Identifiable, Equatable {
    let objectId: String
    let icon: Icon
    let title: String
    let description: String?
    let chatPreview: MessagePreviewModel?
    let parentBadge: ParentObjectUnreadBadge?
    @EquatableNoop var onTap: @MainActor () -> Void

    var id: String { objectId }
}
