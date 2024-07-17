import Foundation
import SwiftUI
import Services

struct DiscussionLinkInputView: View {

    let icon: Icon?
    let title: String
    let description: String
    let onTapRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon {
                IconView(icon: icon)
                    .frame(width: 48, height: 48)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .anytypeStyle(.previewTitle2Medium)
                    .foregroundColor(.Text.primary)
                Text(description)
                    .anytypeStyle(.relation3Regular)
                    .foregroundColor(.Text.secondary)
            }
            .lineLimit(1)
            Spacer()
        }
        .padding(12)
        .frame(height: 72)
        .background(Color.Background.secondary)
        .border(12, color: .Shape.tertiary, lineWidth: 1)
        .shadow(color: .black.opacity(0.05), radius: 4)
        .overlay(alignment: .topTrailing) {
            Button {
                onTapRemove()
            } label: {
                IconView(asset: .X24.removeRed)
            }
            .padding([.top, .trailing], -6)
        }
    }
}

extension DiscussionLinkInputView {
    init(details: ObjectDetails, onTapRemove: @escaping (ObjectDetails) -> Void) {
        self = DiscussionLinkInputView(
            icon: details.objectIconImage,
            title: details.title,
            description: details.objectType.name,
            onTapRemove: { onTapRemove(details) }
        )
    }
}

#Preview {
    DiscussionLinkInputView(
        icon: Icon.object(.placeholder("A")),
        title: "Object Name",
        description: "Object Type",
        onTapRemove: {}
    )
    .padding(16)
    .border(Color.black)
}
