import SwiftUI
import AnytypeCore

struct DashboardWallpaper: View {
    @EnvironmentObject private var model: SettingsViewModel
    
    var body: some View {
        Group {
            switch model.wallpaper {
            case .color(let color):
                Color(hex: color.hex).ignoresSafeArea()
            case .gradient(let gradient):
                Gradients.create(topHexColor: gradient.startHex, bottomHexColor: gradient.endHex)
            }
        }
    }
}

struct DashboardWallpaper_Previews: PreviewProvider {
    static var previews: some View {
        DashboardWallpaper()
    }
}
