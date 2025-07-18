import SwiftUI

struct ChatInputReplyModel {
    let id: String
    let title: String
    let description: String
    let icon: Icon?
}

struct ChatInputReplyView: View {
    
    let model: ChatInputReplyModel
    let onTapDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            if let icon = model.icon {
                IconView(icon: icon)
                    .frame(width: 40, height: 40)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(model.title)
                    .anytypeStyle(.caption1Medium)
                if model.description.isNotEmpty {
                    Text(model.description)
                        .anytypeStyle(.caption1Regular)
                }
            }
            .foregroundStyle(Color.Text.primary)
            .lineLimit(1)
            
            Spacer()
            
            Button {
                onTapDelete()
            } label: {
                Image(asset: .X24.close)
                    .foregroundStyle(Color.Control.primary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(height: 56)
        .background(Color.Background.highlightedLight)
    }
}
