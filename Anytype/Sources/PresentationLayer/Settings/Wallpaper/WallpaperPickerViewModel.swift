import Foundation

@MainActor
final class WallpaperPickerViewModel: ObservableObject {
 
    @Published var wallpaper: BackgroundType = UserDefaultsConfig.wallpaper {
        didSet {
            UserDefaultsConfig.wallpaper = wallpaper
        }
    }
    
    init() {}
}
