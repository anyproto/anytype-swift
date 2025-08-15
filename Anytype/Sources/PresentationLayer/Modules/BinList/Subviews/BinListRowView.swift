import Foundation
import SwiftUI

struct BinListRowModel: Identifiable {
    let objectId: String
    let icon: Icon
    let title: String
    let description: String
    let subtitle: String
    let selected: Bool
    let canDelete: Bool
    let canRestore: Bool
    
    var id: String { objectId }
}

struct BinListRowView: View {
    
    let model: BinListRowModel
    let onTap: () -> Void
    let onCheckboxTap: () -> Void
    let onDelete: () -> Void
    let onRestore: () -> Void
    
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        HStack(spacing: 12) {
            if editMode?.wrappedValue == .active {
                AnytypeCircleCheckbox(checked: model.selected)
            }
            
            WidgetObjectListCommonRowView(
                icon: model.icon,
                title: model.title,
                description: model.description,
                subtitle: model.subtitle
            )
        }
        .padding(.horizontal, 16)
        .fixTappableArea()
        .onTapGesture {
            if editMode?.wrappedValue == .active {
                onCheckboxTap()
            } else {
                onTap()
            }
        }
        .newDivider(leadingPadding: 16, trailingPadding: 16)
        .contextMenu {
            Button(Loc.delete, role: .destructive) {
                onDelete()
            }
            Button(Loc.restore) {
                onRestore()
            }
        }
    }
}
