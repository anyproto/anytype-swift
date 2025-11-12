import SwiftUI

struct NewSpaceCardLastMessageView: View {
    
    let model: MessagePreviewModel
    
    var body: some View {
        Group {
            if model.attachments.isNotEmpty {
                messageWithAttachements
            } else if model.text.isNotEmpty {
                messageWithoutAttachements
            } else {
                AnytypeText(model.creatorTitle ?? Loc.Chat.newMessages, style: .chatPreviewMedium)
                    .foregroundColor(.Text.transparentSecondary)
                    .lineLimit(1)
            }
        }
        .multilineTextAlignment(.leading)
    }
    
    private var messageWithoutAttachements: some View {
        Group {
            if let creatorTitle = model.creatorTitle {
                VStack(alignment: .leading, spacing: 2) {
                    Text(creatorTitle).anytypeFontStyle(.chatPreviewMedium)
                    Text(model.text).anytypeFontStyle(.chatPreviewRegular)
                }
                .lineLimit(1)
            } else {
                Text(model.text).anytypeFontStyle(.chatPreviewRegular)
                    .lineLimit(2)
            }
        }
        .foregroundColor(.Text.transparentSecondary)
        .anytypeLineHeightStyle(.chatPreviewRegular)
    }

    private var messageWithAttachements: some View {
        VStack(alignment: .leading, spacing: 2) {

            if let creatorTitle = model.creatorTitle {
                AnytypeText(creatorTitle, style: .chatPreviewMedium)
                    .foregroundColor(.Text.transparentSecondary)
                    .lineLimit(1)
            }

            HStack(spacing: 2) {
                ForEach(model.attachments) {
                    IconView(icon: $0.icon).frame(width: 18, height: 18)
                }

                Spacer.fixedWidth(2)
                AnytypeText(model.localizedAttachmentsText, style: .chatPreviewRegular)
                    .foregroundColor(.Text.transparentSecondary)
                    .lineLimit(1)
            }
        }
    }
}
