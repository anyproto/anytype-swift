import Foundation
import SwiftUI

struct MessageView: View {
    
    let id: String
    let message: String
    let author: String
    let authorIcon: Icon?
    let date: Date
    let isYourMessage: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            leadingView
            content
            trailingView
        }
        .padding(.horizontal, 8)
    }
    
    private var messageBackgorundColor: Color {
        return isYourMessage ? Color.VeryLight.green : Color.VeryLight.grey
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(author)
                    .anytypeStyle(.previewTitle2Medium)
                    .foregroundColor(.Text.primary)
                Spacer()
                Text(date.formatted(date: .omitted, time: .shortened))
                    .anytypeStyle(.caption1Regular)
                    .foregroundColor(.Text.secondary)
            }
            Text(message)
                .anytypeStyle(.bodyRegular)
                .foregroundColor(.Text.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(messageBackgorundColor)
        .cornerRadius(24, style: .continuous)
        .id(id)
    }
    
    @ViewBuilder
    private var leadingView: some View {
        if isYourMessage {
            Spacer.fixedWidth(32)
        } else {
            IconView(icon: authorIcon)
                .frame(width: 32, height: 32)
        }
    }
    
    @ViewBuilder
    private var trailingView: some View {
        if isYourMessage {
            IconView(icon: authorIcon)
                .frame(width: 32, height: 32)
        } else {
            Spacer.fixedWidth(32)
        }
    }
}

extension MessageView {
    init(block: MessageBlock) {
        self = MessageView(
            id: block.id,
            message: block.text,
            author: block.author.title,
            authorIcon: block.author.icon.map { .object($0) },
            date: block.createDate,
            isYourMessage: block.isYourMessage
        )
    }
}

#Preview("Other") {
    VStack {
        MessageView(
            id: "",
            message:"I think it’d better not to mix all the conversations",
            author: "Megh",
            authorIcon: .image(
                UIImage.circleImage(
                    size: CGSize(width: 32, height: 32),
                    fillColor: .orange,
                    borderColor: .red,
                    borderWidth: 1)
            ),
            date: Date(),
            isYourMessage: false
        )
        
        MessageView(
            id: "",
            message:"I think it’d better not to mix all the conversations",
            author: "Megh",
            authorIcon: .image(
                UIImage.circleImage(
                    size: CGSize(width: 32, height: 32),
                    fillColor: .orange,
                    borderColor: .red,
                    borderWidth: 1)
            ),
            date: Date.init(timeIntervalSinceNow: -500),
            isYourMessage: true
        )
    }
}
