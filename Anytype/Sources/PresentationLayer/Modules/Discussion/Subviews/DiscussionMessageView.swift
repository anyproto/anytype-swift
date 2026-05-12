import Foundation
import SwiftUI
import AnytypeCore

struct DiscussionMessageView: View {

    private enum Constants {
        static let attachmentsPadding: CGFloat = 4
        static let messageHorizontalPadding: CGFloat = 16
        static let messageVerticalPadding: CGFloat = 12
        static let replyBarWidth: CGFloat = 4
        static let replyBarLeadingPadding: CGFloat = 16
        static let replyContentLeadingPadding: CGFloat = 8
        static let replyBarBottomPadding: CGFloat = 12
        static let emoji = ["👍", "️️❤️", "😂"]
    }

    private let data: MessageViewData
    private weak var output: (any MessageModuleOutput)?

    init(
        data: MessageViewData,
        output: (any MessageModuleOutput)? = nil
    ) {
        self.data = data
        self.output = output
    }

    var body: some View {
        content
            .id(data.id)
    }

    private var content: some View {
        messageBody
            .fixTappableArea()
            .messageFlashBackground(id: data.id)
            .background(Color.Background.primary)
    }

    private var messageBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            if data.isReply {
                HStack(alignment: .top, spacing: 0) {
                    Rectangle()
                        .fill(Color.Shape.transparentSecondary)
                        .frame(width: Constants.replyBarWidth)
                        .padding(.leading, Constants.replyBarLeadingPadding)
                        .padding(.bottom, data.isLastReply ? Constants.replyBarBottomPadding : 0)
                    messageInnerContent
                }
            } else {
                messageInnerContent
            }
        }
    }

    private var messageInnerContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            bubble
            reactions
        }
    }

    // Context menu is attached to `bubble` (which excludes the reactions row)
    // so the preview-source rect stays stable when the first reaction is added.
    // Otherwise the dismiss-zoom animation interpolates into a taller rect and
    // clips the comment content (IOS-6074). Padding lives inside the bubble so
    // the full padded comment area is part of the long-press hit region and
    // defines the preview card's shape. The bubble's bottom padding doubles as
    // the visible gap between the last text line and the reactions row below.
    private var bubble: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Spacer.fixedHeight(8)
            messageContent
        }
        .padding(.leading, bubbleLeadingPadding)
        .padding(.trailing, Constants.messageHorizontalPadding)
        .padding(.vertical, Constants.messageVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.Background.primary)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contextMenu {
            contextMenu
        }
    }

    private var bubbleLeadingPadding: CGFloat {
        data.isReply ? Constants.replyContentLeadingPadding : Constants.messageHorizontalPadding
    }

    private var header: some View {
        HStack(spacing: 0) {
            Button {
                if let authorId = data.authorId {
                    output?.didSelectAuthor(authorId: authorId)
                }
            } label: {
                HStack(spacing: 0) {
                    IconView(icon: data.authorIcon)
                        .frame(width: 20, height: 20)

                    Spacer().frame(width: 6)

                    Text(data.authorName.isNotEmpty ? data.authorName : " ")
                        .anytypeStyle(.caption1Medium)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundStyle(Color.Text.primary)

                    if data.isMember {
                        Spacer().frame(width: 4)
                        Image(asset: .X18.membershipBadge)
                    }
                }
            }
            .buttonStyle(.plain)
            .layoutPriority(-1)

            Spacer().frame(width: 8)

            timestampLabel
                .fixedSize()
        }
        .frame(height: 20)
    }

    private var timestampLabel: some View {
        Text(data.timestampLabel)
            .anytypeStyle(.caption1Regular)
            .foregroundStyle(Color.Text.secondary)
            .lineLimit(1)
    }

    @ViewBuilder
    private var messageContent: some View {
        linkedObjectsForTop

        ForEach(data.discussionBlocks) { item in
            DiscussionBlockItemView(block: item.block) { attachmentId in
                if let objectDetails = data.attachmentsDetails.first(where: { $0.id == attachmentId }) {
                    let details = MessageAttachmentDetails(details: objectDetails)
                    output?.didSelectAttachment(data: data, details: details)
                }
            }
            .padding(.top, item.topPadding)
        }
        .tint(Color.Control.accent100)

        linkedObjectsForBottom
    }

    @ViewBuilder
    private var linkedObjectsForTop: some View {
        if let objects = data.linkedObjects {
            switch objects {
            case .list:
                EmptyView()
            case .grid(let items):
                MessageGridAttachmentsContainer(objects: items, spacing: 4) {
                    output?.didSelectAttachment(data: data, details: $0)
                }
                .padding(.vertical, Constants.attachmentsPadding)
            case .bookmark(let item):
                MessageObjectBigBookmarkView(details: item, position: data.position) {
                    output?.didSelectAttachment(data: data, details: $0)
                }
                .padding(.vertical, Constants.attachmentsPadding)
            }
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
                .padding(.vertical, Constants.attachmentsPadding)
            case .grid, .bookmark:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private var reactions: some View {
        if data.reactions.isNotEmpty {
            MessageReactionList(
                rows: data.reactions,
                canAddReaction: data.canAddReaction,
                canToggleReaction: data.canToggleReaction,
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
            .padding(.leading, bubbleLeadingPadding)
            .padding(.trailing, Constants.messageHorizontalPadding)
            .padding(.bottom, Constants.messageVerticalPadding)
        }
    }

    @ViewBuilder
    private var contextMenu: some View {
        if data.canAddReaction {
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
        }

        Divider()

        #if DEBUG || RELEASE_NIGHTLY
        if data.canEdit {
            AsyncButton {
                try await output?.didSelectUnread(message: data)
            } label: {
                Label(Loc.Message.Action.unread, systemImage: "envelope.badge")
            }
        }
        #endif

        if data.canReply {
            Button {
                output?.didSelectReplyTo(message: data)
            } label: {
                Label(Loc.Message.Action.reply, systemImage: "arrowshape.turn.up.left")
            }
        }

        if data.discussionBlocks.hasContent {
            Button {
                output?.didSelectCopyPlainText(message: data)
            } label: {
                Label(Loc.Message.Action.copyPlainText, systemImage: "doc.on.doc")
            }
        }

        Button {
            output?.didSelectCopyLink(message: data)
        } label: {
            Label(Loc.copyLink, systemImage: "link")
        }

        if data.canDelete {
            Button(role: .destructive) {
                output?.didSelectDeleteMessage(message: data)
            } label: {
                Label(Loc.delete, systemImage: "trash")
            }
        }
    }
}
