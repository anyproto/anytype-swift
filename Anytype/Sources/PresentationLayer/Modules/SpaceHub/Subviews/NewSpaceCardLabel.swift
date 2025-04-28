import SwiftUI
import AnytypeCore

// SpaceCardLabel and SpaceCard are splitted for better SwiftUI diff.
struct NewSpaceCardLabel: View {
    
    let spaceData: ParticipantSpaceViewDataWithPreview
    let wallpeper: SpaceWallpaperType
    @Binding var draggedSpace: ParticipantSpaceViewDataWithPreview?
    
    var body: some View {
        HStack(spacing: 12) {
            IconView(icon: spaceData.spaceView.objectIconImage)
                .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 0) {
                Text(spaceData.spaceView.name.withPlaceholder)
                    .anytypeFontStyle(.bodySemibold)
                    .lineLimit(1)
                    .foregroundStyle(Color.Text.primary)
                if FeatureFlags.spaceUxTypes {
                    Text(spaceData.spaceView.uxType.name)
                        .anytypeStyle(.uxTitle2Regular)
                        .lineLimit(2)
                        .foregroundStyle(Color.Text.secondary)
                } else {
                    Text(spaceData.spaceView.spaceAccessType?.name ?? "")
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
        
        .if(spaceData.spaceView.isLoading && !FeatureFlags.newSpacesLoading) { $0.redacted(reason: .placeholder) }
        .contentShape([.dragPreview, .contextMenuPreview], RoundedRectangle(cornerRadius: 20, style: .continuous))
        
        .if(!FeatureFlags.pinnedSpaces || spaceData.spaceView.isPinned) {
            $0.onDrag {
                draggedSpace = spaceData
                return NSItemProvider()
            } preview: {
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    private var counters: some View {
        if spaceData.spaceView.isLoading && FeatureFlags.newSpacesLoading {
            DotsView().frame(width: 30, height: 6)
        } else if spaceData.unreadCount > 0 {
            CounterView(count: spaceData.unreadCount)
        } else if spaceData.spaceView.isPinned {
            Image(asset: .X24.pin).frame(width: 22, height: 22)
        }
    }
}
