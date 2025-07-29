import SwiftUI
import AnytypeCore

// OldSpaceCardLabel and OldSpaceCard are splitted for better SwiftUI diff.
struct OldSpaceCardLabel: View {
    
    let space: ParticipantSpaceViewDataWithPreview
    let wallpeper: SpaceWallpaperType
    @Binding var draggedSpace: ParticipantSpaceViewDataWithPreview?
    
    var body: some View {
        HStack(spacing: 16) {
            IconView(icon: space.space.spaceView.objectIconImage)
                .frame(width: 64, height: 64)
            VStack(alignment: .leading, spacing: 6) {
                Text(space.space.spaceView.name.withPlaceholder)
                    .anytypeFontStyle(.bodySemibold)
                    .lineLimit(1)
                    .foregroundStyle(Color.Text.primary)
                if FeatureFlags.spaceUxTypes {
                    Text(space.space.spaceView.uxType.name)
                        .anytypeStyle(.relation3Regular)
                        .lineLimit(1)
                        .opacity(0.6)
                        .foregroundStyle(Color.Text.primary)
                } else {
                    Text(space.space.spaceView.spaceAccessType?.name ?? "")
                        .anytypeStyle(.relation3Regular)
                        .lineLimit(1)
                        .opacity(0.6)
                        .foregroundStyle(Color.Text.primary)
                }
                Spacer.fixedHeight(1)
            }
            
            Spacer()
            
            if space.space.spaceView.isLoading {
                DotsView().frame(width: 30, height: 6)
//            } else if space.spaceView.unreadMessagesCount > 0 {
//                CounterView(count: space.spaceView.unreadMessagesCount)
//            } else if space.spaceView.isPinned {
//                Image(asset: .X24.pin).frame(width: 22, height: 22)
            }
        }
        .padding(16)
        // Optimization for fast sizeThatFits
        .frame(height: 96)
        .background(
            DashboardWallpaper(
                mode: .spaceHub,
                wallpaper: wallpeper,
                spaceIcon: space.space.spaceView.iconImage
            )
        )
        .cornerRadius(20, style: .continuous)
        
        .contentShape([.dragPreview, .contextMenuPreview], RoundedRectangle(cornerRadius: 20, style: .continuous))
        
//        .if(!FeatureFlags.pinnedSpaces || space.spaceView.isPinned) {
//            $0
                .onDrag {
                draggedSpace = space
                return NSItemProvider()
            } preview: {
                EmptyView()
            }
//        }
    }
}