import Foundation

struct MyFavoritesRowData: Identifiable, Equatable {
    let id: String
    let objectId: String
    let title: String
    let icon: Icon
    @EquatableNoop var onTap: @MainActor () -> Void
}
