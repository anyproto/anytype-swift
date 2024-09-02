import SwiftUI
import AnytypeCore

struct DashboardWallpaper: View {
    
    let wallpaper: SpaceWallpaperType
    let spaceIcon: Icon?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
            ZStack() {
                switch wallpaper {
                case .blurredIcon:
                    IconView(icon: spaceIcon)
                        .scaledToFill()
                        .blur(radius: 32)
                        .clipped()
                        .opacity(colorScheme == .dark ? 0.5 : 0.3)
                case .color(let color):
                    Color(hex: color.data.hex).opacity(0.3)
                case .gradient(let gradient):
                    gradient.data.asLinearGradient().opacity(0.3)
                }
            }
            .ignoresSafeArea()
    }
}

struct DashboardWallpaper_Previews: PreviewProvider {
    static var previews: some View {
        DashboardWallpaper(wallpaper: .default, spaceIcon: .object(.space(.gradient(.random))))
    }
}
