import Foundation
import SwiftUI

struct MessageReplyModel: Equatable, Hashable {
    let author: String
    let description: String
    let icon: Icon?
    let isYour: Bool
}

struct MessageReplyView: View {
    
    let model: MessageReplyModel
    
    var body: some View {
        HStack(spacing: 8) {
            Group {
                model.isYour ? Color.Control.transparentActive : Color.Dark.grey
            }
            .frame(width: 4)
            
            if let icon = model.icon {
                IconView(icon: icon)
                    .frame(width: 32, height: 32)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(model.author)
                    .anytypeStyle(.caption1Medium)
                Text(model.description)
                    .anytypeStyle(.caption1Regular)
            }
            .foregroundStyle(model.isYour ? Color.Text.white : Color.Text.primary)
            .lineLimit(1)
            Spacer(minLength: 12)
        }
        .background(model.isYour ? Color.Control.transparentActive : Color.Light.grey)
        .frame(height: 52)
        .cornerRadius(16)
    }
}
