import SwiftUI
import AnytypeCore

// SpaceCardLabel and SpaceCard are splitted for better SwiftUI diff.
struct NewSpaceCardLabel: View {
    
    let spaceData: ParticipantSpaceViewDataWithPreview
    let wallpaper: SpaceWallpaperType
    private let dateFormatter = HistoryDateFormatter()
    @Binding var draggedSpace: ParticipantSpaceViewDataWithPreview?
    
    @Namespace private var namespace
    
    var body: some View {
        content
            // Delete this line with FeatureFlags.spaceLoadingForScreen
            .if(spaceData.spaceView.isLoading && !FeatureFlags.spaceLoadingForScreen) { $0.redacted(reason: .placeholder) }
            
            .if(spaceData.spaceView.isPinned) {
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
                if let message = spaceData.preview.lastMessage {
                    mainContentWithMessage(message)
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
        .frame(height: 98)
        
        .cornerRadius(20, style: .continuous)
        .background(DashboardWallpaper(
            mode: .spaceHub,
            wallpaper: wallpaper,
            spaceIcon: spaceData.spaceView.iconImage
        ))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    private func mainContentWithMessage(_ message: LastMessagePreview) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                AnytypeText(spaceData.spaceView.name.withPlaceholder, style: .bodySemibold)
                .lineLimit(1)
                .foregroundColor(Color.Text.primary)
                if isMuted {
                    Spacer.fixedWidth(4)
                    Image(asset: .X18.muted).foregroundColor(.Control.transparentSecondary)
                }
                
                Spacer(minLength: 0)
                
                lastMessageDate
            }
            
            HStack(alignment: .top) {
                lastMessagePreview(message)
                Spacer()
                decoration
            }
            
            Spacer(minLength: 0)
        }
    }
    
    private var mainContentWithoutMessage: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                AnytypeText(spaceData.spaceView.name.withPlaceholder, style: .bodySemibold)
                    .lineLimit(1)
                    .foregroundColor(Color.Text.primary)
                if isMuted {
                    Spacer.fixedWidth(8)
                    Image(asset: .X18.muted).foregroundColor(.Control.transparentSecondary)
                }
                Spacer()
                pin
            }
        }
    }
    
    @ViewBuilder
    func lastMessagePreview(_ message: LastMessagePreview) -> some View {
        Group {
            if message.attachments.isNotEmpty {
                messageWithAttachements(message)
            } else if message.text.isNotEmpty {
                messageWithoutAttachements(message)
            } else {
                AnytypeText(message.creator?.title ?? Loc.Chat.newMessages, style: .chatPreviewMedium)
                    .foregroundColor(.Text.primary)
                    .lineLimit(1)
            }
        }
        .multilineTextAlignment(.leading)
    }
    
    func messageWithoutAttachements(_ message: LastMessagePreview) -> some View {
        Group {
            if let creator = message.creator {
                VStack(alignment: .leading, spacing: 2) {
                    Text(creator.title + ": ").anytypeFontStyle(.chatPreviewMedium)
                    Text(message.text).anytypeFontStyle(.chatPreviewRegular)
                }
                .lineLimit(1)
            } else {
                Text(message.text).anytypeFontStyle(.chatPreviewRegular)
                    .lineLimit(2)
            }
        }
        .foregroundColor(.Text.primary)
        .anytypeLineHeightStyle(.chatPreviewRegular)
    }
    
    @ViewBuilder
    func messageWithAttachements(_ message: LastMessagePreview) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            
            if let creator = message.creator {
                AnytypeText(creator.title, style: .chatPreviewMedium)
                    .foregroundColor(.Text.primary)
                    .lineLimit(1)
            }
            
            HStack(spacing: 2) {
                ForEach(message.attachments.prefix(3)) {
                    IconView(icon: $0.objectIconImage).frame(width: 18, height: 18)
                }
                
                Spacer.fixedWidth(4)
                AnytypeText(message.localizedAttachmentsText, style: .chatPreviewRegular)
                    .foregroundColor(.Text.primary)
                    .lineLimit(1)
            }
        }
    }
    
    @ViewBuilder
    private var lastMessageDate: some View {
        if let lastMessage = spaceData.preview.lastMessage {
            AnytypeText(dateFormatter.localizedDateString(for: lastMessage.createdAt, showTodayTime: true), style: .relation2Regular)
                .foregroundColor(.Text.primary)
        }
    }
    
    @ViewBuilder
    private var decoration: some View {
        if spaceData.preview.hasCounters {
            unreadCounters
        } else {
            pin
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
        if spaceData.spaceView.isPinned {
            Image(asset: .X18.pin)
                .foregroundColor(Color.Control.transparentSecondary)
                .frame(width: 18, height: 18)
        }
    }
    
    private var isMuted: Bool {
        FeatureFlags.muteSpacePossibility && !spaceData.spaceView.pushNotificationMode.isUnmutedAll
    }
}
