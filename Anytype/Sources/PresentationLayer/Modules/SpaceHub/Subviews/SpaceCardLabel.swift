import SwiftUI
import AnytypeCore

// SpaceCardLabel and SpaceCard are splitted for better SwiftUI diff.
struct SpaceCardLabel: View {
    
    let spaceData: ParticipantSpaceViewDataWithPreview
    let wallpaper: SpaceWallpaperType
    @Binding var draggedSpace: ParticipantSpaceViewDataWithPreview?
    
    var body: some View {
        HStack(spacing: 16) {
            IconView(icon: spaceData.spaceView.objectIconImage)
                .frame(width: 64, height: 64)
            VStack(alignment: .leading, spacing: 6) {
                Text(spaceData.spaceView.name.withPlaceholder)
                    .anytypeFontStyle(.bodySemibold)
                    .lineLimit(1)
                    .foregroundStyle(Color.Text.primary)
                if FeatureFlags.spaceUxTypes {
                    Text(spaceData.spaceView.uxType.name)
                        .anytypeStyle(.relation3Regular)
                        .lineLimit(1)
                        .opacity(0.6)
                        .foregroundStyle(Color.Text.primary)
                } else {
                    Text(spaceData.spaceView.spaceAccessType?.name ?? "")
                        .anytypeStyle(.relation3Regular)
                        .lineLimit(1)
                        .opacity(0.6)
                        .foregroundStyle(Color.Text.primary)
                }
                Spacer.fixedHeight(1)
            }
            
            Spacer()
            
            if spaceData.spaceView.isLoading && FeatureFlags.newSpacesLoading {
                DotsView().frame(width: 30, height: 6)
            } else if spaceData.preview.unreadCounter > 0 {
                CounterView(count: spaceData.preview.unreadCounter)
            }
        }
        .padding(16)
        // Optimization for fast sizeThatFits
        .frame(height: 96)
        .background(
            DashboardWallpaper(
                mode: .spaceHub,
                wallpaper: wallpaper,
                spaceIcon: spaceData.spaceView.iconImage
            )
        )
        .cornerRadius(20, style: .continuous)
        
        .if(spaceData.spaceView.isLoading && !FeatureFlags.newSpacesLoading) { $0.redacted(reason: .placeholder) }
        .contentShape([.dragPreview, .contextMenuPreview], RoundedRectangle(cornerRadius: 20, style: .continuous))
        
        .onDrag {
            draggedSpace = spaceData
            return NSItemProvider()
        } preview: {
            EmptyView()
        }
    }
}
