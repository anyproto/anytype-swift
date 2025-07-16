import Foundation
import SwiftUI
import AnytypeCore

struct MessageView: View {
    
    private enum Constants {
        static let attachmentsPadding: CGFloat = 4
        static let messageHorizontalPadding: CGFloat = 12
        static let coordinateSpace = "MessageViewCoordinateSpace"
        static let emoji = ["👍🏻", "️️❤️", "😂"]
    }
    
    private let data: MessageViewData
    private weak var output: (any MessageModuleOutput)?
    
    @State private var bubbleCenterOffsetY: CGFloat = 0
    
    @Environment(\.messageYourBackgroundColor) private var messageYourBackgroundColor
    
    init(
        data: MessageViewData,
        output: (any MessageModuleOutput)? = nil
    ) {
        self.data = data
        self.output = output
    }
    
    var body: some View {
        MessageReplyActionView(
            isEnabled: FeatureFlags.swipeToReply && data.canReply,
            contentHorizontalPadding: Constants.messageHorizontalPadding,
            centerOffsetY: $bubbleCenterOffsetY,
            content: {
                alignedСontent
            },
            action: {
                output?.didSelectReplyTo(message: data)
            }
        )
        .id(data.id)
    }
    
    private var alignedСontent: some View {
        HStack(alignment: .bottom, spacing: 6) {
            leadingView
            content
            trailingView
        }
        .padding(.horizontal, Constants.messageHorizontalPadding)
        .padding(.bottom, data.nextSpacing.height)
        .fixTappableArea()
        .coordinateSpace(name: Constants.coordinateSpace)
    }
    
    private var content: some View {
        VStack(alignment: data.position.isRight ? .trailing : .leading, spacing: 4) {
            reply
            author
            bubble
            reactions
        }
        .if(UIDevice.isPad) {
            $0.frame(maxWidth: 350, alignment: data.position.isRight ? .trailing : .leading)
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
            
            linkedObjectsForTop
            
            if !data.messageString.isEmpty {
                // Add spacing for date
                (Text(data.messageString) + infoForSpacing)
                    .anytypeStyle(.chatText)
                    .padding(.horizontal, 12)
                    .alignmentGuide(.timeVerticalAlignment) { $0[.bottom] }
                    .padding(.vertical, 4)
            }
            
            linkedObjectsForBottom
        }
        .overlay(alignment: Alignment(horizontal: .trailing, vertical: .timeVerticalAlignment)) {
            if !data.messageString.isEmpty {
                infoView
                    .padding(.horizontal, 12)
            }
        }
        .messageFlashBackground(id: data.id)
        .background(messageBackgorundColor)
        .cornerRadius(16, style: .continuous)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16, style: .circular))
        .contextMenu {
            contextMenu
        }
        .readFrame(space: .named(Constants.coordinateSpace)) {
            bubbleCenterOffsetY = $0.midY
        }
    }
    
    @ViewBuilder
    private var linkedObjectsForTop: some View {
        if let objects = data.linkedObjects {
            switch objects {
            case .list:
                attachmentFreeSpacing
            case .grid(let items):
                MessageGridAttachmentsContainer(objects: items, spacing: 4) {
                    output?.didSelectAttachment(data: data, details: $0)
                }
                .padding(Constants.attachmentsPadding)
            case .bookmark(let item):
                MessageObjectBigBookmarkView(details: item, position: data.position) {
                    output?.didSelectAttachment(data: data, details: $0)
                }
                .padding(Constants.attachmentsPadding)
            }
        } else {
            attachmentFreeSpacing
        }
    }
    
    @ViewBuilder
    private var linkedObjectsForBottom: some View {
        if let objects = data.linkedObjects {
            switch objects {
            case .list(let items):
                MessageListAttachmentsViewContainer(objects: items, position: data.position) {
                    output?.didSelectAttachment(data: data, details: $0)
                }
                .padding(Constants.attachmentsPadding)
            case .grid, .bookmark:
                attachmentFreeSpacing
            }
        } else {
            attachmentFreeSpacing
        }
    }
    
    @ViewBuilder
    private var attachmentFreeSpacing: some View {
        if !data.messageString.isEmpty {
            Spacer.fixedHeight(4)
        } else {
            EmptyView()
        }
    }
    
    private var infoView: some View {
        Text(messageBottomInfo: data)
            .foregroundColor(messageTimeColor)
            .lineLimit(1)
    }
    
    private var infoForSpacing: Text {
        Text(messageBottomInfo: data)
            .foregroundColor(.clear)
    }
    
    @ViewBuilder
    private var reactions: some View {
        if data.reactions.isNotEmpty {
            MessageReactionList(
                rows: data.reactions,
                canAddReaction: data.canAddReaction,
                position: data.position,
                onTapRow: { reaction in
                    try await output?.didTapOnReaction(data: data, emoji: reaction.emoji)
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
        if data.position.isRight {
            horizontalBubbleSpacing
        } else {
            authorIcon
        }
    }
    
    @ViewBuilder
    private var trailingView: some View {
        if data.position.isRight {
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
    
    private var horizontalBubbleSpacing: some View {
        Spacer(minLength: 26)
    }
    
    @ViewBuilder
    private var contextMenu: some View {
        if data.canAddReaction {
            if #available(iOS 16.4, *) {
                ControlGroup {
                    ForEach(Constants.emoji, id:\.self) { emoji in
                        AsyncButton {
                            try await output?.didTapOnReaction(data: data, emoji: emoji)
                        } label: {
                            Text(emoji)
                        }
                    }
                    Button {
                        output?.didSelectAddReaction(messageId: data.message.id)
                    } label: {
                        Image(asset: .Reactions.selectEmoji)
                    }
                }
                .controlGroupStyle(.compactMenu)
            } else {
                
                Button {
                    output?.didSelectAddReaction(messageId: data.message.id)
                } label: {
                    Label(Loc.Message.Action.addReaction, systemImage: "face.smiling")            
                }
            }
        }
        
        Divider()
        
        #if DEBUG || RELEASE_NIGHTLY
        AsyncButton {
            try await output?.didSelectUnread(message: data)
        } label: {
            Text(Loc.Message.Action.unread)
        }
        #endif
        
        if data.canReply {
            Button {
                output?.didSelectReplyTo(message: data)
            } label: {
                Label(Loc.Message.Action.reply, systemImage: "arrowshape.turn.up.left")
            }
        }
        
        if !data.messageString.isEmpty {   
            Button {
                output?.didSelectCopyPlainText(message: data)
            } label: {
                Label(Loc.Message.Action.copyPlainText, systemImage: "doc.on.doc")
            }
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
        return data.position.isRight ? messageYourBackgroundColor : .Background.Chat.bubbleSomeones
    }
    
    private var messageTimeColor: Color {
        return data.position.isRight ? Color.Background.Chat.whiteTransparent : Color.Control.transparentActive
    }
}

private struct TimeVerticalAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        return context[.bottom]
    }
}

private extension VerticalAlignment {
    static let timeVerticalAlignment = VerticalAlignment(TimeVerticalAlignment.self)
}
