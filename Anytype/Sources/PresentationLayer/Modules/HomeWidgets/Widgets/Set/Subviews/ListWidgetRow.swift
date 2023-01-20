import Foundation
import SwiftUI

struct ListWidgetRow: View {
    
    struct Model {
        let objectId: String
        let icon: ObjectIconImage?
        let title: String
        let description: String?
        let onTap: () -> Void
    }
    
    let model: Model
    
    var body: some View {
        Button {
            model.onTap()
        } label: {
            HStack(spacing: 12) {
                if let icon = model.icon {
                    SwiftUIObjectIconImageView(
                        iconImage: icon,
                        usecase: .homeSetWidget
                    ).frame(width: 48, height: 48)
                }
                VStack(alignment: .leading, spacing: 1) {
                    AnytypeText(model.title, style: .previewTitle2Medium, color: .Text.primary)
                        .lineLimit(1)
                    if let description = model.description {
                        AnytypeText(description, style: .relation3Regular, color: .Text.secondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 72)
        .newDivider(leadingPadding: 16, trailingPadding: 16)
    }
}
