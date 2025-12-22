import SwiftUI

struct WidgetObjectListCommonRowView: View {
    
    let icon: Icon
    let title: String
    let description: String?
    let subtitle: String?
    
    var body: some View {
        HStack(spacing: 0) {
            IconView(icon: icon)
                .frame(width: 48, height: 48)
            
            Spacer.fixedWidth(12)
            
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(title, style: .previewTitle2Medium)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)
                if let description = description, description.isNotEmpty {
                    Spacer.fixedHeight(1)
                    AnytypeText(description, style: .relation3Regular)
                        .foregroundStyle(descriptionColor)
                        .lineLimit(1)
                }
                if let subtitle = subtitle, subtitle.isNotEmpty {
                    Spacer.fixedHeight(2)
                    AnytypeText(subtitle, style: .relation3Regular)
                        .foregroundStyle(Color.Text.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .frame(height: 72)
    }
    
    private var descriptionColor: Color {
        return (subtitle?.isEmpty ?? true) ? .Text.secondary : .Text.primary
    }
}
