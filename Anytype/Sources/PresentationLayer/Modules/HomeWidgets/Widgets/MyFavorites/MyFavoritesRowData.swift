import Foundation

struct MyFavoritesRowData: Identifiable, Equatable {
    let id: String
    let objectId: String
    let title: String
    let icon: Icon
    let chatPreview: MessagePreviewModel?
    @EquatableNoop var onTap: @MainActor () -> Void
}
