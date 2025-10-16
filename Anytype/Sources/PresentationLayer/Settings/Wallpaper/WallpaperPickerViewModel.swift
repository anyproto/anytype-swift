import Foundation

@MainActor
final class WallpaperPickerViewModel: ObservableObject {
    
    @Published var wallpaper: SpaceWallpaperType {
        didSet {
            userDefaults.setWallpaper(spaceId: spaceId, wallpaper: wallpaper)
        }
    }
    
    var spaceIcon: Icon? { spaceStorage.spaceView(spaceId: spaceId)?.objectIconImage }
    
    private let userDefaults: any UserDefaultsStorageProtocol
    @Injected(\.spaceViewsStorage)
    private var spaceStorage: any SpaceViewsStorageProtocol
    
    private let spaceId: String    
    
    init(spaceId: String) {
        self.spaceId = spaceId
        
        let userDefaults = Container.shared.userDefaultsStorage()
        self.userDefaults = userDefaults
        wallpaper = userDefaults.wallpaper(spaceId: spaceId)
    }
}
