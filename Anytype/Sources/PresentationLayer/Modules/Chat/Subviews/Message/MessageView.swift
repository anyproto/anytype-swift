import Foundation
import SwiftUI

struct MessageView: View {
    
    private enum Constants {
        static let attachmentsSize: CGFloat = 250
        static let attachmentsPadding: CGFloat = 4
    }
    
    private let data: MessageViewData
    private weak var output: (any MessageModuleOutput)?
    
    @State private var contentSize: CGSize = .zero
    @State private var headerSize: CGSize = .zero
    @Environment(\.messageYourBackgroundColor) private var messageYourBackgroundColor
    
    init(
        data: MessageViewData,
        output: (any MessageModuleOutput)? = nil
    ) {
        self.data = data
        self.output = output
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            leadingView
            content
            trailingView
        }
        .padding(.horizontal, 12)
        .padding(.bottom, data.nextSpacing.height)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 4) {
            reply
            author
            bubble
            reactions
        }
    }
    
    @ViewBuilder
    private var reply: some View {
        if let reply = data.replyModel {
            MessageReplyView(model: reply)
                .onTapGesture {
                    output?.didSelectReplyMessage(message: data)
                }
        }
    }
    
    @ViewBuilder
    private var author: some View {
        if data.showAuthorName {
            Text(data.authorName.isNotEmpty ? data.authorName : " ") // Safe height if participant is not loaded
                .anytypeStyle(.caption1Medium)
                .lineLimit(1)
                .foregroundStyle(Color.Text.primary)
                .padding(.horizontal, 12)
        }
    }
    
    private var bubble: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            linkedObjects
            
            if !data.messageString.isEmpty {
                
                if data.linkedObjects.isNil {
                    Spacer.fixedHeight(12)
                } else {
                    Spacer.fixedHeight(4)
                }
                
                // Add spacing for date
                (Text(data.messageString) + createDateTextForSpacing)
                    .anytypeStyle(.previewTitle1Regular)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if !data.messageString.isEmpty {
                createDate
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
            }
        }
        .frame(width: fixedBubbleWidth)
        .background(messageBackgorundColor)
        .cornerRadius(20, style: .continuous)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .circular))
        .contextMenu {
            contextMenu
        }
    }
    
    @ViewBuilder
    private var linkedObjects: some View {
        if let objects = data.linkedObjects {
            switch objects {
            case .list(let items):
                MessageListAttachmentsViewContainer(objects: items) {
                    output?.didSelectAttachment(data: data, details: $0)
                }
                .frame(width: Constants.attachmentsSize)
                .padding(Constants.attachmentsPadding)
            case .grid(let items):
                MessageGridAttachmentsContainer(objects: items, oneSide: Constants.attachmentsSize, spacing: 4) {
                    output?.didSelectAttachment(data: data, details: $0)
                }
                .padding(Constants.attachmentsPadding)
            case .bookmark(let item):
                MessageObjectBigBookmarkView(details: item)
                    .frame(width: Constants.attachmentsSize)
                    .padding(Constants.attachmentsPadding)
            }
        }
    }
    
    private var fixedBubbleWidth: CGFloat? {
        data.linkedObjects.isNotNil ? Constants.attachmentsSize + Constants.attachmentsPadding * 2 : nil
    }
    
    private var createDate: some View {
        Text(data.createDate)
            .anytypeFontStyle(.caption2Regular)
            .lineLimit(1)
            .foregroundColor(messageTimeColor)
    }
    
    private var createDateTextForSpacing: Text {
        (Text("  ") + Text(data.createDate))
            .anytypeFontStyle(.caption2Regular)
            .foregroundColor(.clear)
    }
    
    @ViewBuilder
    private var reactions: some View {
        if data.reactions.isNotEmpty {
            MessageReactionList(
                rows: data.reactions,
                canAddReaction: data.canAddReaction,
                isYourMessage: data.isYourMessage,
                onTapRow: { reaction in
                    try await output?.didTapOnReaction(data: data, reaction: reaction)
                },
                onLongTapRow: { reaction in
                    output?.didLongTapOnReaction(data: data, reaction: reaction)
                },
                onTapAdd: {
                    output?.didSelectAddReaction(messageId: data.message.id)
                }
            )
        }
    }
    
    @ViewBuilder
    private var leadingView: some View {
        if data.isYourMessage {
            horizontalBubbleSpacing
        } else {
            authorIcon
        }
    }
    
    @ViewBuilder
    private var trailingView: some View {
        if data.isYourMessage {
            authorIcon
        } else {
            horizontalBubbleSpacing
        }
    }
    
    @ViewBuilder
    private var authorIcon: some View {
        switch data.authorIconMode {
        case .show:
            Button {
                if let authorId = data.authorId {
                    output?.didSelectAuthor(authorId: authorId)
                }
            } label: {
                IconView(icon: data.authorIcon)
                    .frame(width: 32, height: 32)
            }
        case .empty:
            Spacer.fixedWidth(32)
        case .hidden:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var horizontalBubbleSpacing: some View {
        switch data.authorIconMode {
        case .show, .empty:
            Spacer(minLength: 32)
        case .hidden:
            Spacer(minLength: 64)
        }
    }
    
    @ViewBuilder
    private var contextMenu: some View {
        if data.canAddReaction {
            Button {
                output?.didSelectAddReaction(messageId: data.message.id)
            } label: {
                Label(Loc.Message.Action.addReaction, systemImage: "face.smiling")            
            }
        }
        
        Divider()
        
        Button {
            output?.didSelectReplyTo(message: data)
        } label: {
            Label(Loc.Message.Action.reply, systemImage: "arrowshape.turn.up.left")
        }
        
        if data.canEdit {
            AsyncButton {
                await output?.didSelectEditMessage(message: data)
            } label: {
                Label(Loc.edit, systemImage: "pencil")
            }
        }
        
        if data.canDelete {
            Button(role: .destructive) {
                output?.didSelectDeleteMessage(message: data)
            } label: {
                Label(Loc.delete, systemImage: "trash")
            }
        }
    }
    
    private var messageBackgorundColor: Color {
        return data.isYourMessage ? messageYourBackgroundColor : .Background.Chat.bubbleSomeones
    }
    
    private var messageTimeColor: Color {
        return data.isYourMessage ? Color.Background.Chat.replySomeones : Color.Control.transparentActive
    }
}
