import SwiftUI

struct InstalledObjectTypeView: View {
    
    let model: InstalledObjectTypeViewModel
    
    var body: some View {
        Button {
            model.onTap()
        } label: {
            HStack(spacing: 0) {
                IconView(icon: model.icon)
                    .frame(width: 18, height: 18)
                if let title = model.title {
                    Spacer.fixedWidth(8)
                    AnytypeText(title, style: .uxCalloutMedium, color: .Text.primary)
                }
            }
            .frame(height: 48)
            .padding(.leading, model.title.isNil ? 15 : 14)
            .padding(.trailing, model.title.isNil ? 15 : 16)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        model.isSelected ? Color.System.amber50 : Color.Stroke.primary,
                        lineWidth: model.isSelected ? 2 : 1
                    )
            )
        }
    }
}
