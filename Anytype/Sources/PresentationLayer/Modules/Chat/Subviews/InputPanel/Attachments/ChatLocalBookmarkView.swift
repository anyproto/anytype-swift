import Foundation
import SwiftUI

struct ChatLocalBookmark: Identifiable, Hashable, Equatable {
    let url: String
    let title: String
    let description: String
    let icon: Icon
    let loading: Bool
    
    var id: Int { hashValue }
}

extension ChatLocalBookmark {
    static func placeholder(url: URL) -> Self {
        ChatLocalBookmark(
            url: url.absoluteString,
            title: url.absoluteString,
            description: "Placeholder",
            icon: .object(.empty(.page)),
            loading: true
        )
    }
}

struct ChatLocalBookmarkView: View {
    
    let model: ChatLocalBookmark
    let onTapObject: () -> Void
    let onTapRemove: () -> Void
    
    var body: some View {
        MessageCommonBookmarkView(
            icon: model.icon,
            title: model.title,
            description: model.description,
            style: .chatInput
        )
        .onTapGesture {
            onTapObject()
        }
        .messageLinkObjectStyle()
        .messageLinkRemoveButton(onTapRemove: onTapRemove)
    }
}
