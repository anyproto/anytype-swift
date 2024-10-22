import Foundation
import SwiftUI

struct MessageReplyModel {
    let author: String
    let description: AttributedString
    let icon: Icon?
    let isYour: Bool
}

struct MessageReplyView: View {
    
    let model: MessageReplyModel
    
    var body: some View {
        HStack(spacing: 8) {
            Group {
                model.isYour ? Color.Dark.green : Color.Dark.grey
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
            .foregroundStyle(Color.Text.primary)
            .lineLimit(1)
            Spacer(minLength: 12)
        }
        .background(model.isYour ? Color.Light.green : Color.Light.grey)
        .frame(height: 52)
        .cornerRadius(16)
    }
}
