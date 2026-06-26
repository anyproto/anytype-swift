import Foundation

struct ListWidgetRowModel: Identifiable, Equatable {
    let objectId: String
    let icon: Icon
    let title: String
    let description: String?
    let chatPreview: MessagePreviewModel?
    let parentBadge: ParentObjectUnreadBadge?
    // Navigation identity compared by Equatable so re-render guards rebuild the row
    // (and its onTap) when routing changes even if rendered fields stay the same.
    let screenData: ScreenData
    @EquatableNoop var onTap: @MainActor () -> Void

    var id: String { objectId }
}
