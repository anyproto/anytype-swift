import Foundation
import SwiftUI

struct ListWidgetRow: View {
    
    struct Model {
        let objectId: String
        let icon: ObjectIconImage?
        let title: String
        let description: String?
        let type: String?
        let onTap: () -> Void
    }
    
    let model: Model
    static let height: CGFloat = 72
    
    var body: some View {
        Button {
            model.onTap()
        } label: {
            HStack(spacing: 12) {
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
                    if let type = model.type, type.isNotEmpty {
                        Spacer.fixedHeight(2)
                        AnytypeText(type, style: .relation3Regular, color: .Text.secondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .frame(height: ListWidgetRow.height)
        .newDivider(leadingPadding: 16, trailingPadding: 16)
    }
    
    private var descriptionColor: Color {
        return (model.type?.isEmpty ?? true) ? .Text.secondary : .Text.primary
    }
}
