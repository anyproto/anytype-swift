import SwiftUI
import AnytypeCore

enum DashboardWallpaperMode {
    case `default`
    case spaceHub
    case parallax(containerHeight: CGFloat)
    
    var containerHeight: CGFloat? {
        switch self {
        case .default, .spaceHub:
            return nil
        case .parallax(let height):
            return height
        }
    }
}

struct DashboardWallpaper: View {
    
    let mode: DashboardWallpaperMode
    let wallpaper: SpaceWallpaperType
    let spaceIcon: Icon?
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var viewLocation = CGPointZero
    @State private var imageSize = CGSizeZero
    
    init(mode: DashboardWallpaperMode = .default, wallpaper: SpaceWallpaperType, spaceIcon: Icon?) {
        self.mode = mode
        self.wallpaper = wallpaper
        self.spaceIcon = spaceIcon
    }
    
    private var iconOpacity: CGFloat {
        switch mode {
        case .default:
            0.3
        case .parallax, .spaceHub:
            colorScheme == .dark ? 0.5 : 0.3
        }
    }
    
    var body: some View {
            ZStack() {
                switch wallpaper {
                case .blurredIcon:
                    IconView(icon: spaceIcon)
                        .scaledToFill()
                        .scaleEffect(1.2)
                        .ifLet(mode.containerHeight) { view, height in
                            view
                                .readSize { imageSize = $0 }
                                .offset(y: parallaxOffset(containerHeight: height))
                                .background(PositionCatcher { viewLocation = $0 })
                        }
                        .blur(radius: 32)
                        .clipped()
                        .opacity(iconOpacity)
                        .overlay(colorOverlay)
                case .color(let color):
                    Color(hex: color.data.hex).opacity(0.3)
                case .gradient(let gradient):
                    gradient.data.asLinearGradient().opacity(0.3)
                }
            }
            .ignoresSafeArea()
    }
    
    private var colorOverlay: some View {
        colorScheme == .dark ? Color.white.opacity(0.02) : Color.black.opacity(0.02)
    }
    
    private func parallaxOffset(containerHeight: CGFloat) -> CGFloat {
        let offsetFromCenter = containerHeight / 2 - viewLocation.y
        let relativeOffset = offsetFromCenter / containerHeight
        
        return relativeOffset * imageSize.height
    }
}

struct DashboardWallpaper_Previews: PreviewProvider {
    static var previews: some View {
        DashboardWallpaper(wallpaper: .default, spaceIcon: .object(.space(.mock)))
    }
}
