import SwiftUI

struct DiscussionInputReplyModel {
    let id: String
    let title: String
    let description: AttributedString
    let icon: Icon?
}

struct DiscussionInputReplyView: View {
    
    let model: DiscussionInputReplyModel
    let onTapDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            if let icon = model.icon {
                IconView(icon: icon)
                    .frame(width: 24, height: 24)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(model.title)
                    .anytypeStyle(.caption1Medium)
                Text(model.description)
                    .anytypeStyle(.caption1Regular)
            }
            .foregroundStyle(Color.Text.primary)
            .lineLimit(1)
            
            Spacer()
            
            Button {
                onTapDelete()
            } label: {
                Image(asset: .X24.close)
                    .foregroundStyle(Color.Button.button)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(Color.Background.highlightedLight)
    }
}
