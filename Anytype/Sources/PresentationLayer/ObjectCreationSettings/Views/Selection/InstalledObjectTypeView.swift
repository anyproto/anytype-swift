import SwiftUI

struct InstalledObjectTypeView: View {
    
    let model: InstalledObjectTypeViewModel
    
    var body: some View {
        Button {
            model.onTap()
        } label: {
            HStack(spacing: 8) {
                if let icon = model.icon {
                    IconView(icon: icon)
                        .frame(width: 18, height: 18)
                }
                if let title = model.title {
                    AnytypeText(title, style: .uxCalloutMedium)
                        .foregroundColor(.Text.primary)
                }
            }
            .frame(height: 48)
            .padding(.leading, model.title.isNil ? 15 : 14)
            .padding(.trailing, model.title.isNil ? 15 : 16)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        model.isSelected ? Color.Control.accent50 : Color.Shape.primary,
                        lineWidth: model.isSelected ? 2 : 1
                    )
            )
        }
    }
}
