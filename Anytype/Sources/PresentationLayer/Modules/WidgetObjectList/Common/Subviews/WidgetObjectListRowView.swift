import Foundation
import SwiftUI

struct WidgetObjectListRowView: View {
    
    let model: WidgetObjectListRowModel
    
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        HStack(spacing: 12) {
            if editMode?.wrappedValue == .active {
                AnytypeCircleCheckbox(checked: model.isChecked)
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
            if isActiveEditMode {
                model.onCheckboxTap?()
            } else {
                model.onTap()
            }
        }
        .newDivider(leadingPadding: 16, trailingPadding: 16)
        .contextMenu {
            contextMenu()
        }
    }
    
    private var descriptionColor: Color {
        return (model.subtitle?.isEmpty ?? true) ? .Text.secondary : .Text.primary
    }
    
    private var isActiveEditMode: Bool {
        editMode?.wrappedValue == .active
    }
    
    @ViewBuilder
    private func contextMenu() -> some View {
        if !isActiveEditMode {
            ForEach(model.menu) { menu in
                Button(menu.title, role: menu.negative ? .destructive : nil) {
                    Task { @MainActor in
                        menu.onTap()
                    }
                }
            }
        }
    }
}
