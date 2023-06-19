import Foundation
import SwiftUI

struct ListWidgetRow: View {
    
    struct Model: Identifiable {
        let objectId: String
        let icon: ObjectIconImage?
        let title: String
        let description: String?
        let subtitle: String?
        let isChecked: Bool
        let onTap: () -> Void
        let onCheckboxTap: (() -> Void)?
        
        var id: String { objectId }
    }
    
    let model: Model
    
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        HStack(spacing: 12) {
            if editMode?.wrappedValue == .active {
                checkboxView
            }
            if let icon = model.icon {
                SwiftUIObjectIconImageView(
                    iconImage: icon,
                    usecase: .widgetList
                ).frame(width: 48, height: 48)
            }
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(model.title, style: .previewTitle2Medium, color: .Text.primary)
                    .lineLimit(1)
                if let description = model.description, description.isNotEmpty {
                    Spacer.fixedHeight(1)
                    AnytypeText(description, style: .relation3Regular, color: descriptionColor)
                        .lineLimit(1)
                }
                if let subtitle = model.subtitle, subtitle.isNotEmpty {
                    Spacer.fixedHeight(2)
                    AnytypeText(subtitle, style: .relation3Regular, color: .Text.secondary)
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
                .foregroundColor(.Button.active)
        }
    }
    
    private var isActiveEditMode: Bool {
        editMode?.wrappedValue == .active
    }
}
