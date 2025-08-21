import SwiftUI
import AnytypeCore

// SpaceCardLabel and SpaceCard are splitted for better SwiftUI diff.
struct NewSpaceCardLabel: View {
    
    let spaceData: ParticipantSpaceViewDataWithPreview
    let wallpaper: SpaceWallpaperType
    let draggable: Bool
    private let dateFormatter = HistoryDateFormatter()
    @Binding var draggedSpace: ParticipantSpaceViewDataWithPreview?
    
    @Namespace private var namespace
    
    var body: some View {
        content
            // Delete this line with FeatureFlags.spaceLoadingForScreen
            .if(spaceData.spaceView.isLoading && !FeatureFlags.spaceLoadingForScreen) { $0.redacted(reason: .placeholder) }
            
            .if((!FeatureFlags.pinnedSpaces && draggable) || spaceData.spaceView.isPinned) {
                $0.onDrag {
                    draggedSpace = spaceData
                    return NSItemProvider()
                } preview: {
                    EmptyView()
                }
            }
    }
    
    private var content: some View {
        HStack(alignment: .center, spacing: 12) {
            IconView(icon: spaceData.spaceView.objectIconImage)
                .frame(width: 64, height: 64)
            
            Group {
                if spaceData.preview.lastMessage.isNotNil {
                    mainContentWithMessage
                } else {
                    mainContentWithoutMessage
                }
            }
            // Fixing the animation when the cell is moved and updated inside
            // Optimization - create a data model for SpaceCard and map to in in SpaceHubViewModel on background thread
            .id(spaceData.hashValue)
            .matchedGeometryEffect(id: "content", in: namespace, properties: .position, anchor: .topLeading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        // Optimization for fast sizeThatFits
        .frame(height: 96)
        
        .cornerRadius(20, style: .continuous)
        .background(DashboardWallpaper(
            mode: .spaceHub,
            wallpaper: wallpaper,
            spaceIcon: spaceData.spaceView.iconImage
        ))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    private var mainContentWithMessage: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(spaceData.spaceView.name.withPlaceholder)
                    .anytypeFontStyle(.bodySemibold)
                    .lineLimit(1)
                    .foregroundStyle(Color.Text.primary)
                if isMuted {
                    Spacer.fixedWidth(8)
                    Image(asset: .X18.muted).foregroundColor(.Control.secondary)
                }
                Spacer(minLength: 8)
                lastMessageDate
            }
            HStack {
                info
                Spacer()
                unreadCounters
                pin
            }
            Spacer(minLength: 1)
        }
    }
    
    private var mainContentWithoutMessage: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(spaceData.spaceView.name.withPlaceholder)
                    .anytypeFontStyle(.bodySemibold)
                    .lineLimit(1)
                    .foregroundStyle(Color.Text.primary)
                if isMuted {
                    Spacer.fixedWidth(8)
                    Image(asset: .X18.muted).foregroundColor(.Control.transparentSecondary)
                }
                Spacer()
                pin
            }
        }
    }

    
    private var info: some View {
        Group {
            if let lastMessage = spaceData.preview.lastMessage {
                lastMessagePreview(lastMessage)
                    .foregroundStyle(Color.Text.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    @ViewBuilder
    func lastMessagePreview(_ message: LastMessagePreview) -> some View {
        Group {
            if message.text.isNotEmpty {
                // Do not show attachements due to SwiftUI limitations:
                // Can not fit attachements in between two lines of text with proper multiline behaviour
                messageWithoutAttachements(message)
            } else if message.attachments.isNotEmpty {
                // Show attachements and 1 line of text
                messageWithAttachements(message)
            } else {
                Text(message.creator?.title ?? Loc.Chat.newMessages)
                    .anytypeStyle(.uxTitle2Medium).lineLimit(1)
            }
        }
    }
    
    func messageWithoutAttachements(_ message: LastMessagePreview) -> some View {
        Group {
            if let creator = message.creator {
                Text(creator.title + ": ").anytypeFontStyle(.uxTitle2Medium) +
                Text(message.text).anytypeFontStyle(.uxTitle2Regular)
            } else {
                Text(message.text).anytypeFontStyle(.uxTitle2Regular)
            }
        }.lineLimit(2).anytypeLineHeightStyle(.uxTitle2Regular)
    }
    
    @ViewBuilder
    func messageWithAttachements(_ message: LastMessagePreview) -> some View {
        HStack(spacing: 2) {
            if let creator = message.creator {
                Text(creator.title + ":").anytypeStyle(.uxTitle2Medium).lineLimit(1)
                Spacer.fixedWidth(4)
            }
            
            ForEach(message.attachments.prefix(3)) {
                IconView(icon: $0.objectIconImage).frame(width: 18, height: 18)
            }
            
            Spacer.fixedWidth(4)
            Text(message.localizedAttachmentsText).anytypeStyle(.uxTitle2Regular).lineLimit(1)
        }
    }
    
    @ViewBuilder
    private var lastMessageDate: some View {
        if let lastMessage = spaceData.preview.lastMessage {
            Text(dateFormatter.localizedDateString(for: lastMessage.createdAt, showTodayTime: true))
                .anytypeStyle(.relation2Regular)
                .foregroundStyle(Color.Control.transparentSecondary)
        }
    }
    
    private var unreadCounters: some View {
        HStack(spacing: 4) {
            if spaceData.preview.mentionCounter > 0 {
                MentionBadge(style: isMuted ? .muted : .highlighted)
            }
            if spaceData.preview.unreadCounter > 0 {
                CounterView(
                    count: spaceData.preview.unreadCounter,
                    style: isMuted ? .muted : .highlighted
                )
            }
        }
    }
    
    @ViewBuilder
    private var pin: some View {
        if !spaceData.preview.hasCounters && FeatureFlags.pinnedSpaces && spaceData.spaceView.isPinned {
            Image(asset: .X24.pin)
                .foregroundStyle(Color.Control.transparentSecondary)
                .frame(width: 22, height: 22)
        }
    }
    
    private var isMuted: Bool {
        FeatureFlags.muteSpacePossibility && !spaceData.spaceView.pushNotificationMode.isUnmutedAll
    }
}
