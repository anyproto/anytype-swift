import SwiftUI
import AnytypeCore

// NewSpaceCardLabel and SpaceCard are splitted for better SwiftUI diff.
struct NewSpaceCardLabel: View {

    let model: SpaceCardModel
    @Binding var draggedSpaceViewId: String?

    @Namespace private var namespace

    private let iconSize: CGFloat = 40
    private let verticalPadding: CGFloat = 16
    private let cellHeight: CGFloat = 72
    private var showCompactPreview: Bool {
        model.supportsMultiChats && model.hasCounters && model.multichatCompactPreview != nil
    }
    private var showSingleChatMessage: Bool {
        !model.supportsMultiChats && model.lastMessage != nil
    }
    private var previewTextColor: Color {
        (!model.supportsMultiChats && model.hasCounters) ? Color.Text.primary : Color.Text.transparentSecondary
    }

    var body: some View {
        content
            .onDragIf(model.isPinned) {
                draggedSpaceViewId = model.spaceViewId
                return NSItemProvider()
            } preview: {
                EmptyView()
            }
    }

    private var content: some View {
        HStack(alignment: .center, spacing: 12) {
            IconView(icon: model.objectIconImage)
                .frame(width: iconSize, height: iconSize)

            mainContent
                .matchedGeometryEffect(id: "content", in: namespace, properties: .position, anchor: .topLeading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, verticalPadding)
        // Optimization for fast sizeThatFits
        .frame(height: cellHeight)

        .clipShape(.rect(cornerRadius: 20, style: .continuous))
        .background(DashboardWallpaper(
            mode: .spaceHub,
            wallpaper: model.wallpaper,
            spaceIcon: model.objectIconImage
        ))
        .background(Color.Background.primary)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    @ViewBuilder
    private var mainContent: some View {
        if showCompactPreview, let preview = model.multichatCompactPreview {
            compactMultichatContent(preview)
        } else if showSingleChatMessage, let message = model.lastMessage {
            mainContentWithMessage(message)
        } else {
            mainContentWithoutMessage
        }
    }
    
    private func mainContentWithMessage(_ message: MessagePreviewModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .bottom) {
                HStack(alignment: .center) {
                    AnytypeText(model.nameWithPlaceholder, style: .bodySemibold)
                        .lineLimit(1)
                        .foregroundStyle(Color.Text.primary)
                    if model.isMuted {
                        Spacer.fixedWidth(4)
                        Image(asset: .X18.muted).foregroundStyle(Color.Control.transparentSecondary)
                    }
                }

                Spacer(minLength: 8)

                VStack(spacing: 0) {
                    lastMessageDate
                    Spacer.fixedHeight(2)
                }
            }

            HStack(alignment: .top) {
                NewSpaceCardLastMessageView(model: message, supportsMultiChats: model.supportsMultiChats, showsMessageAuthor: model.showsMessageAuthor, previewTextColor: previewTextColor)
                Spacer()
                decoration
            }

            Spacer(minLength: 0)
        }
    }

    private var mainContentWithoutMessage: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                AnytypeText(model.nameWithPlaceholder, style: .bodySemibold)
                    .lineLimit(1)
                    .foregroundStyle(Color.Text.primary)
                if model.isMuted {
                    Spacer.fixedWidth(8)
                    Image(asset: .X18.muted).foregroundStyle(Color.Control.transparentSecondary)
                }
                Spacer()
                pin
            }
        }
    }

    private func compactMultichatContent(_ preview: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .bottom) {
                HStack(alignment: .center) {
                    AnytypeText(model.nameWithPlaceholder, style: .bodySemibold)
                        .lineLimit(1)
                        .foregroundStyle(Color.Text.primary)
                    if model.isMuted {
                        Spacer.fixedWidth(4)
                        Image(asset: .X18.muted).foregroundStyle(Color.Control.transparentSecondary)
                    }
                }

                Spacer(minLength: 8)

                VStack(spacing: 0) {
                    lastMessageDate
                    Spacer.fixedHeight(2)
                }
            }

            HStack(alignment: .top) {
                AnytypeText(preview, style: .chatPreviewMedium)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)
                Spacer()
                decoration
            }

            Spacer(minLength: 0)
        }
    }
    
    @ViewBuilder
    private var lastMessageDate: some View {
        if let dateText = compactPreviewDateText {
            AnytypeText(dateText, style: .relation2Regular)
                .foregroundStyle(Color.Control.transparentSecondary)
        }
    }

    private var compactPreviewDateText: String? {
        if model.supportsMultiChats {
            return model.lastUnreadDateText
        }
        return model.lastMessage?.chatPreviewDate
    }

    @ViewBuilder
    private var decoration: some View {
        if model.hasCounters {
            unreadCounters
        } else {
            pin
        }
    }

    private var unreadCounters: some View {
        HStack(spacing: 4) {
            if model.hasUnreadReactions {
                HeartBadge(style: model.reactionStyle)
            }
            if model.mentionCounter > 0 {
                MentionBadge(style: model.mentionCounterStyle)
            }
            if model.unreadCounter > 0 {
                CounterView(
                    count: model.unreadCounter,
                    style: model.unreadCounterStyle
                )
            }
        }
    }

    @ViewBuilder
    private var pin: some View {
        if model.isPinned {
            Image(asset: .X18.pin)
                .foregroundStyle(Color.Control.transparentSecondary)
                .frame(width: 18, height: 18)
        }
    }
}
