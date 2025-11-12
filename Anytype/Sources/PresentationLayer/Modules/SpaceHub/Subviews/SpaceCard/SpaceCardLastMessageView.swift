import SwiftUI

struct SpaceCardLastMessageView: View {
    
    let model: MessagePreviewModel
    
    var body: some View {
        if model.text.isNotEmpty {
            // Do not show attachements due to SwiftUI limitations:
            // Can not fit attachements in between two lines of text with proper multiline behaviour
            messageWithoutAttachements
        } else if model.attachments.isNotEmpty {
            // Show attachements and 1 line of text
            messageWithAttachements
        } else {
            Text(model.creatorTitle ?? Loc.Chat.newMessages)
                .anytypeStyle(.uxTitle2Medium).lineLimit(1)
        }
    }
    
    private var messageWithoutAttachements: some View {
        Group {
            if let creatorTitle = model.creatorTitle {
                Text(creatorTitle + ": ").anytypeFontStyle(.uxTitle2Medium) +
                Text(model.text).anytypeFontStyle(.uxTitle2Regular)
            } else {
                Text(model.text).anytypeFontStyle(.uxTitle2Regular)
            }
        }.lineLimit(2).anytypeLineHeightStyle(.uxTitle2Regular)
    }

    private var messageWithAttachements: some View {
        HStack(spacing: 2) {
            if let creatorTitle = model.creatorTitle {
                Text(creatorTitle + ":").anytypeStyle(.uxTitle2Medium).lineLimit(1)
                Spacer.fixedWidth(4)
            }

            ForEach(model.attachments) {
                IconView(icon: $0.icon).frame(width: 18, height: 18)
            }

            Spacer.fixedWidth(4)
            Text(model.localizedAttachmentsText).anytypeStyle(.uxTitle2Regular).lineLimit(1)
        }
    }
}
