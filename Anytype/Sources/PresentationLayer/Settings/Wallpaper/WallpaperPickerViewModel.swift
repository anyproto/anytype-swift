import Foundation

@MainActor
final class WallpaperPickerViewModel: ObservableObject {
 
    private let spaceId: String
    
    @Published var wallpaper: BackgroundType {
        didSet {
            UserDefaultsConfig.setWallpaper(spaceId: spaceId, wallpaper: wallpaper)
        }
    }
    
    init(spaceId: String) {
        self.spaceId = spaceId
        wallpaper = UserDefaultsConfig.wallpaper(spaceId: spaceId)
    }
}
