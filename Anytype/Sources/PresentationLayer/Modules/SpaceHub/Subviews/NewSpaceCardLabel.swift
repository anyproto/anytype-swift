import SwiftUI
import AnytypeCore

// SpaceCardLabel and SpaceCard are splitted for better SwiftUI diff.
struct NewSpaceCardLabel: View {
    
    let spaceData: ParticipantSpaceViewDataWithPreview
    let wallpaper: SpaceWallpaperType
    private let dateFormatter = HistoryDateFormatter()
    @Binding var draggedSpace: ParticipantSpaceViewDataWithPreview?
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            IconView(icon: spaceData.spaceView.objectIconImage)
                .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 0) {
                Text(spaceData.spaceView.name.withPlaceholder)
                    .anytypeFontStyle(.bodySemibold)
                    .lineLimit(1)
                    .foregroundStyle(Color.Text.primary)
                info
                Spacer(minLength: 1)
            }
            
            Spacer(minLength: 8)
            
            counters
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        // Optimization for fast sizeThatFits
        .frame(height: 80)
        .background(Color.Background.primary)
        
        .if(spaceData.spaceView.isLoading && !FeatureFlags.newSpacesLoading) { $0.redacted(reason: .placeholder) }
        .contentShape([.dragPreview, .contextMenuPreview], RoundedRectangle(cornerRadius: 20, style: .continuous))
        
        .onDrag {
            draggedSpace = spaceData
            return NSItemProvider()
        } preview: {
            EmptyView()
        }
    }
    
    private var info: some View {
        Group {
            if let lastMessage = spaceData.preview.lastMessage {
                lastMessagePreview(lastMessage)
            } else if FeatureFlags.spaceUxTypes {
                Text(spaceData.spaceView.uxType.name)
                    .anytypeStyle(.uxTitle2Regular)
            } else {
                Text(spaceData.spaceView.spaceAccessType?.name ?? "")
                    .anytypeStyle(.uxTitle2Regular)
            }
        }
        .lineLimit(2)
        .foregroundStyle(Color.Text.secondary)
        .multilineTextAlignment(.leading)
    }
    
    // TBD: Image preview
    @ViewBuilder
    func lastMessagePreview(_ message: LastMessagePreview) -> some View {
        Group {
            if let creator = message.creator {
                Text(creator.localName + ": ").anytypeFontStyle(.uxTitle2Medium) +
                Text(message.messagePreviewText).anytypeFontStyle(.uxTitle2Regular)
            } else {
                Text(message.messagePreviewText).anytypeFontStyle(.uxTitle2Regular)
            }
        }.anytypeLineHeightStyle(.uxTitle2Regular)
    }
    
    @ViewBuilder
    private var counters: some View {
        if spaceData.spaceView.isLoading && FeatureFlags.newSpacesLoading {
            DotsView().frame(width: 30, height: 6)
        } else {
            VStack(spacing: 2) {
                createdDate
                unreadCounters
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var createdDate: some View {
        if let lastMessage = spaceData.preview.lastMessage {
            Text(dateFormatter.localizedDateString(for: lastMessage.createdAt, showTodayTime: true))
                .anytypeStyle(.relation2Regular)
                .foregroundStyle(Color.Control.transparentActive)
        }
    }
    
    private var unreadCounters: some View {
        HStack(spacing: 4) {
            if spaceData.preview.mentionCounter > 0 {
                MentionBadge()
            }
            if spaceData.preview.unreadCounter > 0 {
                CounterView(count: spaceData.preview.unreadCounter)
            }
        }
    }
}
