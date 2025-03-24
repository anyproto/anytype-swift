import SwiftUI
import AnytypeCore
import Services
import CachedAsyncImage

enum DashboardWallpaperMode: Hashable {
    case `default`
    case spaceHub
}

struct DashboardWallpaper: View {
    
    let mode: DashboardWallpaperMode
    let wallpaper: SpaceWallpaperType
    let spaceIcon: Icon?
    
    init(mode: DashboardWallpaperMode = .default, wallpaper: SpaceWallpaperType, spaceIcon: Icon?) {
        self.mode = mode
        self.wallpaper = wallpaper
        self.spaceIcon = spaceIcon
    }
    
    var body: some View {
            ZStack() {
                switch wallpaper {
                case .blurredIcon:
                    DashboardWallpaperBluerredIcon(mode: mode, spaceIcon: spaceIcon)
                        .equatable()
                case .color(let color):
                    Color(hex: color.data.hex).opacity(0.3)
                case .gradient(let gradient):
                    CoverGradientView(data: gradient.data)
                        .equatable()
                        .opacity(0.3)
                }
            }
            .ignoresSafeArea()
        
    }
}

private struct DashboardWallpaperBluerredIcon: View, Equatable {
    
    let mode: DashboardWallpaperMode
    let spaceIcon: Icon?
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        switch spaceIcon {
        case let .object(.space(icon)):
            spaceIconView(spaceIcon: icon)
                .clipped()
                .opacity(iconOpacity)
                .overlay(colorOverlay)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func spaceIconView(spaceIcon: ObjectIcon.Space) -> some View {
        switch spaceIcon {
        case let .name(_, iconOption):
            IconColorStorage.iconColor(iconOption: iconOption)
        case .imageId(let imageId):
            CachedAsyncImage(
                url: ImageMetadata(id: imageId, side: .width(50)).contentUrl
            ) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .padding(-64)
                    .blur(radius: 32)
            } placeholder: {
                LoadingPlaceholderIconView()
            }
        }
    }
    
    private var iconOpacity: CGFloat {
        switch mode {
        case .default:
            0.3
        case .spaceHub:
            colorScheme == .dark ? 0.5 : 0.3
        }
    }
    
    private var colorOverlay: some View {
        colorScheme == .dark ? Color.white.opacity(0.02) : Color.black.opacity(0.02)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.mode == rhs.mode && lhs.spaceIcon == rhs.spaceIcon
    }
}

struct DashboardWallpaper_Previews: PreviewProvider {
    static var previews: some View {
        DashboardWallpaper(wallpaper: .default, spaceIcon: .object(.space(.mock)))
    }
}
