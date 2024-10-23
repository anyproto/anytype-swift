import Foundation
import Services

@MainActor
final class HomeWallpaperViewModel: ObservableObject {
    
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    
    private let spaceInfo: AccountInfo
    
    @Published var wallpaper: SpaceWallpaperType = .default
    @Published var spaceIcon: Icon?
    
    init(spaceInfo: AccountInfo) {
        self.spaceInfo = spaceInfo
        self.spaceIcon = workspaceStorage.spaceView(spaceId: spaceInfo.accountSpaceId)?.objectIconImage
    }
    
    func subscribeOnWallpaper() async {
        for await newWallpaper in userDefaults.wallpaperPublisher(spaceId: spaceInfo.accountSpaceId).values {
            wallpaper = newWallpaper
        }
    }
    
    func subscribeOnSpace() async {
        for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: spaceInfo.accountSpaceId).values {
            spaceIcon = spaceView.objectIconImage
        }
    }
}
