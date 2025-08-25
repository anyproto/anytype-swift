import SwiftUI
import AnytypeCore

// SpaceCardLabel and SpaceCard are splitted for better SwiftUI diff.
struct SpaceCardLabel: View {
    
    let spaceData: ParticipantSpaceViewDataWithPreview
    let wallpaper: SpaceWallpaperType
    let draggable: Bool
    private let dateFormatter = HistoryDateFormatter()
    @Binding var draggedSpace: ParticipantSpaceViewDataWithPreview?
    
    @Namespace private var namespace
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            IconView(icon: spaceData.spaceView.objectIconImage)
                .frame(width: 56, height: 56)
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
                    createdDate
                }
                HStack {
                    info
                    Spacer()
                    unreadCounters
                    pin
                }
                Spacer(minLength: 1)
            }
            // Fixing the animation when the cell is moved and updated inside
            // Optimization - create a data model for SpaceCard and map to in in SpaceHubViewModel on background thread
            .id(spaceData.hashValue)
            .matchedGeometryEffect(id: "content", in: namespace, properties: .position, anchor: .topLeading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        // Optimization for fast sizeThatFits
        .frame(height: 80)
        .background(Color.Background.primary)
        // Delete this line with FeatureFlags.spaceLoadingForScreen
        .if(spaceData.spaceView.isLoading && !FeatureFlags.spaceLoadingForScreen) { $0.redacted(reason: .placeholder) }
        .contentShape([.dragPreview, .contextMenuPreview], RoundedRectangle(cornerRadius: 20, style: .continuous))
        
        .if((!FeatureFlags.pinnedSpaces && draggable) || spaceData.spaceView.isPinned) {
            $0.onDrag {
                draggedSpace = spaceData
                return NSItemProvider()
            } preview: {
                EmptyView()
            }
        }
    }
    
    private var info: some View {
        Group {
            if let lastMessage = spaceData.preview.lastMessage {
                lastMessagePreview(lastMessage)
            } else if FeatureFlags.spaceUxTypes {
                Text(spaceData.spaceView.uxType.name)
                    .anytypeStyle(.uxTitle2Regular)
                    .lineLimit(1)
            } else {
                Text(spaceData.spaceView.spaceAccessType?.name ?? "")
                    .anytypeStyle(.uxTitle2Regular)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(Color.Text.secondary)
        .multilineTextAlignment(.leading)
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
    private var createdDate: some View {
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
            Image(asset: .X18.pin)
                .foregroundStyle(Color.Control.secondary)
                .frame(width: 18, height: 18)
        }
    }
    
    private var isMuted: Bool {
        FeatureFlags.muteSpacePossibility && !spaceData.spaceView.pushNotificationMode.isUnmutedAll
    }
}
