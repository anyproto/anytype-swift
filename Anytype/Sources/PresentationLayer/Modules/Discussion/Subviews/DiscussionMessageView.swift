import Foundation
import SwiftUI
import AnytypeCore

struct DiscussionMessageView: View {

    private enum Constants {
        static let attachmentsPadding: CGFloat = 4
        static let messageHorizontalPadding: CGFloat = 16
        static let coordinateSpace = "DiscussionMessageViewCoordinateSpace"
        static let emoji = ["👍", "️️❤️", "😂"]
    }

    private let data: MessageViewData
    private weak var output: (any MessageModuleOutput)?

    @State private var contentCenterOffsetY: CGFloat = 0

    init(
        data: MessageViewData,
        output: (any MessageModuleOutput)? = nil
    ) {
        self.data = data
        self.output = output
    }

    var body: some View {
        MessageReplyActionView(
            isEnabled: data.canReply,
            contentHorizontalPadding: Constants.messageHorizontalPadding,
            centerOffsetY: $contentCenterOffsetY,
            content: {
                content
            },
            action: {
                output?.didSelectReplyTo(message: data)
            }
        )
        .id(data.id)
    }

    private var content: some View {
        messageBody
            .fixTappableArea()
            .coordinateSpace(name: Constants.coordinateSpace)
            .messageFlashBackground(id: data.id)
            .background(Color.Background.primary)
            .contentShape(.contextMenuPreview, Rectangle())
            .contextMenu {
                contextMenu
            } preview: {
                messageBody
                    .background(Color.Background.primary)
            }
            .readFrame(space: .named(Constants.coordinateSpace)) {
                contentCenterOffsetY = $0.midY
            }
    }

    private var messageBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            reply
            messageContent
            reactions
        }
        .padding(.horizontal, Constants.messageHorizontalPadding)
        .padding(.bottom, data.nextSpacing.height)
    }

    @ViewBuilder
    private var header: some View {
        if data.showAuthorName {
            Divider()
                .foregroundStyle(Color.Shape.tertiary)
                .padding(.top, 4)

            HStack(spacing: 8) {
                Button {
                    if let authorId = data.authorId {
                        output?.didSelectAuthor(authorId: authorId)
                    }
                } label: {
                    HStack(spacing: 8) {
                        IconView(icon: data.authorIcon)
                            .frame(width: 28, height: 28)

                        Text(data.authorName.isNotEmpty ? data.authorName : " ")
                            .anytypeStyle(.caption1Medium)
                            .lineLimit(1)
                            .foregroundStyle(Color.Text.primary)
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                Text(data.createDate)
                    .anytypeStyle(.caption2Regular)
                    .foregroundStyle(Color.Text.secondary)
            }
            .padding(.top, 12)
            .padding(.bottom, 4)
        }
    }

    @ViewBuilder
    private var reply: some View {
        if let reply = data.replyModel {
            Button {
                output?.didSelectReplyMessage(message: data)
            } label: {
                MessageReplyView(model: reply)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 4)
        }
    }

    @ViewBuilder
    private var messageContent: some View {
        linkedObjectsForTop

        if !data.messageString.isEmpty {
            Text(data.messageString)
                .anytypeStyle(.chatText)
                .padding(.vertical, 2)
        }

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
                canToggleReaction: data.canAddReaction,
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
            .padding(.top, 4)
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

        if !data.messageString.isEmpty {
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
}
