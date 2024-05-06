import SwiftUI

struct SetSortTypeItem: Identifiable {
    let id = UUID()
    let title: String
    let isSelected: Bool
    var onTap: () -> Void
}
