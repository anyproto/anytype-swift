import Foundation
import Services

@MainActor
@Observable
final class HomeWallpaperViewModel {

    @ObservationIgnored
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol

    private let spaceId: String

    var wallpaper: SpaceWallpaperType = .default
    var spaceIcon: Icon?
    
    init(spaceId: String) {
        self.spaceId = spaceId
        self.spaceIcon = workspaceStorage.spaceView(spaceId: spaceId)?.objectIconImage
    }
    
    func subscribeOnWallpaper() async {
        for await newWallpaper in userDefaults.wallpaperPublisher(spaceId: spaceId).values {
            wallpaper = newWallpaper
        }
    }
    
    func subscribeOnSpace() async {
        for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: spaceId).values {
            spaceIcon = spaceView.objectIconImage
        }
    }
}
