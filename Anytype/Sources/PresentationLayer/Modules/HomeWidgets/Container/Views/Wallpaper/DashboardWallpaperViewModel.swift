import Foundation

final class DashboardWallpaperViewModel: ObservableObject {
    
    @Published private(set) var wallpaper: BackgroundType = .default
    
    init() {
        UserDefaultsConfig.wallpaperPublisher
            .assign(to: &$wallpaper)
    }
}
