import Foundation
import SwiftUI
import Services

struct MessageCommonBookmarkView: View {
    
    let icon: Icon
    let title: String
    let description: String
    let style: MessageAttachmentStyle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                IconView(icon: icon)
                    .frame(width: 14, height: 14)
                Text(title)
                    .anytypeStyle(.caption1Regular)
                    .foregroundColor(style.titleColor.suColor)
                    .lineLimit(1)
                    .padding(.bottom, 5)
                Spacer()
            }
            Text(description)
                .anytypeStyle(.uxTitle2Medium)
                .foregroundColor(style.descriptionColor.suColor)
                .lineLimit(1)
        }
        .padding(12)
    }
}
