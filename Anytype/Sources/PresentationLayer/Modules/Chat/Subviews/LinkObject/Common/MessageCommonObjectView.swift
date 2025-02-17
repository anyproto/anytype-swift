import Foundation
import SwiftUI
import Services

struct MessageCommonObjectView: View {
    
    let icon: Icon
    let title: String
    let description: String
    let isYour: Bool
    let size: String?
    
    var body: some View {
        HStack(spacing: 12) {
            IconView(icon: icon)
                .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .anytypeStyle(.previewTitle2Medium)
                    .foregroundColor(isYour ? .Text.white : .Text.primary)
                HStack(spacing: 6) {
                    Text(description)
                        .anytypeStyle(.relation3Regular)
                    if let size {
                        Circle()
                            .fill(Color.Text.secondary)
                            .frame(width: 3, height: 3)
                        Text(size)
                            .anytypeStyle(.relation3Regular)
                    }
                }
                .foregroundColor(isYour ? .Background.Chat.whiteTransparent : .Control.transparentActive)
            }
            .lineLimit(1)
            Spacer()
        }
        .padding(12)
    }
}
