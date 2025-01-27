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
        VStack(alignment: .leading, spacing: 2) {
            author
            bubble
        }
    }
    
    private var author: some View {
        Text(model.author)
            .anytypeStyle(.caption1Medium)
            .foregroundStyle(Color.Control.transparentActive)
            .padding(.horizontal, 16)
    }
    
    private var bubble: some View {
        HStack(spacing: 6) {
            if let icon = model.icon {
                IconView(icon: icon)
                    .frame(width: 16, height: 16)
            }
            Text(model.description)
                .anytypeStyle(.caption1Regular)
                .foregroundStyle(Color.Control.transparentActive)
                .lineLimit(3)
        }
        .padding(8)
        .background(messageBackgorundColor)
        .cornerRadius(16, style: .continuous)
        .padding(.leading, 8)
        .overlay(alignment: .leading) {
            Color.Shape.transperentPrimary
                .frame(width: 4)
                .cornerRadius(2)
        }
    }
    
    private var messageBackgorundColor: Color {
        return model.isYour ? .Background.primary : .Shape.transperentSecondary
    }
}
