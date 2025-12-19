import Foundation

@MainActor
@Observable
final class WallpaperPickerViewModel {

    var wallpaper: SpaceWallpaperType {
        didSet {
            userDefaults.setWallpaper(spaceId: spaceId, wallpaper: wallpaper)
        }
    }

    var spaceIcon: Icon? { spaceStorage.spaceView(spaceId: spaceId)?.objectIconImage }

    @ObservationIgnored
    private let userDefaults: any UserDefaultsStorageProtocol
    @ObservationIgnored @Injected(\.spaceViewsStorage)
    private var spaceStorage: any SpaceViewsStorageProtocol

    @ObservationIgnored
    private let spaceId: String    
    
    init(spaceId: String) {
        self.spaceId = spaceId
        
        let userDefaults = Container.shared.userDefaultsStorage()
        self.userDefaults = userDefaults
        wallpaper = userDefaults.wallpaper(spaceId: spaceId)
    }
}
