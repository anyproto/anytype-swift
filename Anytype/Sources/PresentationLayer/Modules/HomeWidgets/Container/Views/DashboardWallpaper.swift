import SwiftUI
import AnytypeCore

struct DashboardWallpaper: View {
    
    let wallpaper: BackgroundType
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            switch wallpaper {
            case .color(let color):
                Color(hex: color.data.hex)
            case .gradient(let gradient):
                gradient.data.asLinearGradient()
            }
            
            if colorScheme == .dark {
                Color.black.opacity(0.5)
            }
        }
        .ignoresSafeArea()
    }
}

struct DashboardWallpaper_Previews: PreviewProvider {
    static var previews: some View {
        DashboardWallpaper(wallpaper: .default)
    }
}
