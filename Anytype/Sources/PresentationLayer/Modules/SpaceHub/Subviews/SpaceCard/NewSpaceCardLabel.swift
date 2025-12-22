import SwiftUI
import AnytypeCore

// NewSpaceCardLabel and SpaceCard are splitted for better SwiftUI diff.
struct NewSpaceCardLabel: View {

    let model: SpaceCardModel
    @Binding var draggedSpaceViewId: String?

    @Namespace private var namespace
    
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
                .frame(width: 56, height: 56)

            Group {
                if let message = model.lastMessage {
                    mainContentWithMessage(message)
                } else {
                    mainContentWithoutMessage
                }
            }
            .matchedGeometryEffect(id: "content", in: namespace, properties: .position, anchor: .topLeading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 17)
        // Optimization for fast sizeThatFits
        .frame(height: 98)

        .cornerRadius(20, style: .continuous)
        .background(DashboardWallpaper(
            mode: .spaceHub,
            wallpaper: model.wallpaper,
            spaceIcon: model.objectIconImage
        ))
        .background(Color.Background.primary)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
                NewSpaceCardLastMessageView(model: message, supportsMultiChats: model.supportsMultiChats, showsMessageAuthor: model.showsMessageAuthor)
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
    
    @ViewBuilder
    private var lastMessageDate: some View {
        if let lastMessage = model.lastMessage {
            AnytypeText(lastMessage.chatPreviewDate, style: .relation2Regular)
                .foregroundStyle(Color.Control.transparentSecondary)
        }
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
