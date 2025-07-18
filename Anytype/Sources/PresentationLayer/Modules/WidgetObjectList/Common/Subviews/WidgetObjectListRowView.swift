import Foundation
import SwiftUI

struct WidgetObjectListRowView: View {
    
    let model: WidgetObjectListRowModel
    
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        HStack(spacing: 12) {
            if editMode?.wrappedValue == .active {
                checkboxView
            }
            
            IconView(icon: model.icon)
                .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(model.title, style: .previewTitle2Medium)
                    .foregroundColor(.Text.primary)
                    .lineLimit(1)
                if let description = model.description, description.isNotEmpty {
                    Spacer.fixedHeight(1)
                    AnytypeText(description, style: .relation3Regular)
                        .foregroundColor(descriptionColor)
                        .lineLimit(1)
                }
                if let subtitle = model.subtitle, subtitle.isNotEmpty {
                    Spacer.fixedHeight(2)
                    AnytypeText(subtitle, style: .relation3Regular)
                        .foregroundColor(.Text.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 72)
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
    
    @ViewBuilder
    private var checkboxView: some View {
        if model.isChecked {
            Image(asset: .PageBlock.Checkbox.marked)
        } else {
            Image(asset: .PageBlock.Checkbox.empty)
                .foregroundColor(.Control.secondary)
        }
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
