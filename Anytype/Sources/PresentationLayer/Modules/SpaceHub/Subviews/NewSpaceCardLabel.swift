import SwiftUI
import AnytypeCore

// SpaceCardLabel and SpaceCard are splitted for better SwiftUI diff.
struct NewSpaceCardLabel: View {
    
    let space: ParticipantSpaceViewData
    let wallpeper: SpaceWallpaperType
    @Binding var draggedSpace: ParticipantSpaceViewData?
    
    var body: some View {
        HStack(spacing: 12) {
            IconView(icon: space.spaceView.objectIconImage)
                .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 0) {
                Text(space.spaceView.name.withPlaceholder)
                    .anytypeFontStyle(.bodySemibold)
                    .lineLimit(1)
                    .foregroundStyle(Color.Text.primary)
                if FeatureFlags.spaceUxTypes {
                    Text(space.spaceView.uxType.name)
                        .anytypeStyle(.uxTitle2Regular)
                        .lineLimit(2)
                        .foregroundStyle(Color.Text.secondary)
                } else {
                    Text(space.spaceView.spaceAccessType?.name ?? "")
                        .anytypeStyle(.uxTitle2Regular)
                        .lineLimit(2)
                        .foregroundStyle(Color.Text.secondary)
                }
                Spacer()
            }
            
            Spacer()
            
            counters
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        // Optimization for fast sizeThatFits
        .frame(height: 80)
        .background(Color.Background.primary)
        
        .if(space.spaceView.isLoading && !FeatureFlags.newSpacesLoading) { $0.redacted(reason: .placeholder) }
        .contentShape([.dragPreview, .contextMenuPreview], RoundedRectangle(cornerRadius: 20, style: .continuous))
        
        .if(!FeatureFlags.pinnedSpaces || space.spaceView.isPinned) {
            $0.onDrag {
                draggedSpace = space
                return NSItemProvider()
            } preview: {
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    private var counters: some View {
        if space.spaceView.isLoading && FeatureFlags.newSpacesLoading {
            DotsView().frame(width: 30, height: 6)
        } else if space.spaceView.unreadMessagesCount > 0 {
            CounterView(count: space.spaceView.unreadMessagesCount)
        } else if space.spaceView.isPinned {
            Image(asset: .X24.pin).frame(width: 22, height: 22)
        }
    }
}
