import AnytypeCore
import Services
import Combine
import SwiftUI

enum LastOpenedScreen: Codable {
    case editor(EditorScreenData)
    case widgets(spaceId: String)
    case chat(ChatCoordinatorData)
    case spaceChat(SpaceChatCoordinatorData)
    
    var spaceId: String {
        switch self {
        case .editor(let data):
            data.spaceId
        case .widgets(let spaceId):
            spaceId
        case .chat(let data):
            data.spaceId
        case .spaceChat(let data):
            data.spaceId
        }
    }
}

protocol UserDefaultsStorageProtocol: AnyObject, Sendable {
    var showUnstableMiddlewareError: Bool { get set }
    var currentVersionOverride: String { get set }
    var installedAtDate: Date? { get set }
    var analyticsUserConsent: Bool { get set }
    var defaultObjectTypes: [String: String] { get set }
    var rowsPerPageInSet: Int { get set }
    var rowsPerPageInGroupedSet: Int { get set }
    var userInterfaceStyle: UIUserInterfaceStyle { get set }
    var lastOpenedScreen: LastOpenedScreen? { get set }
    
    
    func wallpaperPublisher(spaceId: String) -> AnyPublisher<SpaceWallpaperType, Never>
    func wallpapersPublisher() -> AnyPublisher<[String: SpaceWallpaperType], Never>
    func wallpaper(spaceId: String) -> SpaceWallpaperType
    func setWallpaper(spaceId: String, wallpaper: SpaceWallpaperType)

    func homeObjectId(spaceId: String) -> String?
    func setHomeObjectId(spaceId: String, objectId: String?)
    func homeObjectIdPublisher(spaceId: String) -> AnyPublisher<String?, Never>

    func cleanStateAfterLogout()
}

final class UserDefaultsStorage: UserDefaultsStorageProtocol, @unchecked Sendable {
    @UserDefault("showUnstableMiddlewareError", defaultValue: true)
    var showUnstableMiddlewareError: Bool
    
    @UserDefault("UserData.CurrentVersionOverride", defaultValue: "")
    var currentVersionOverride: String
    
    @UserDefault("App.InstalledAtDate", defaultValue: nil)
    var installedAtDate: Date?
    
    @UserDefault("App.AnalyticsUserConsent", defaultValue: false)
    var analyticsUserConsent: Bool
    
    // Key - spaceId, value - objectTypeId
    @UserDefault("UserData.DefaultObjectTypes", defaultValue: [:])
    var defaultObjectTypes: [String: String]
    
    @UserDefault("UserData.RowsPerPageInSet", defaultValue: 50)
    var rowsPerPageInSet: Int
    
    @UserDefault("UserData.RowsPerPageInGroupedSet", defaultValue: 20)
    var rowsPerPageInGroupedSet: Int
    
    @UserDefault("UserData.LastOpenedScreen.NewKey", defaultValue: nil)
    var lastOpenedScreen: LastOpenedScreen?
    
    @UserDefault("serverConfig", defaultValue: .anytype)
    private var serverConfig: NetworkServerConfig
    
    // MARK: - UserInterfaceStyle
    @UserDefault("UserData.UserInterfaceStyle", defaultValue: UIUserInterfaceStyle.unspecified.rawValue)
    private var _userInterfaceStyleRawValue: Int
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        get { UIUserInterfaceStyle(rawValue: _userInterfaceStyleRawValue) ?? .unspecified }
        set {
            _userInterfaceStyleRawValue = newValue.rawValue

            AnytypeAnalytics.instance().logSelectTheme(userInterfaceStyle)
        }
    }
    
    // MARK: - Wallpaper
    @UserDefault("UserData.Wallpapers", defaultValue: [:])
    private var _wallpapers: [String: SpaceWallpaperType] {
        didSet { wallpapersSubject.send(_wallpapers) }
    }
    
    private lazy var wallpapersSubject = CurrentValueSubject<[String: SpaceWallpaperType], Never>(_wallpapers)
    func wallpapersPublisher() -> AnyPublisher<[String: SpaceWallpaperType], Never> {
        wallpapersSubject.eraseToAnyPublisher()
    }
    
    func wallpaperPublisher(spaceId: String) -> AnyPublisher<SpaceWallpaperType, Never> {
        return wallpapersSubject
            .compactMap { items -> SpaceWallpaperType in
                return items[spaceId] ?? .default
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func wallpaper(spaceId: String) -> SpaceWallpaperType {
        return _wallpapers[spaceId] ?? .default
    }
    
    func setWallpaper(spaceId: String, wallpaper: SpaceWallpaperType) {
        _wallpapers[spaceId] = wallpaper
    }

    // MARK: - Home Object
    @UserDefault("UserData.HomeObjects", defaultValue: [:])
    private var _homeObjects: [String: String] {
        didSet { homeObjectsSubject.send(_homeObjects) }
    }

    private lazy var homeObjectsSubject = CurrentValueSubject<[String: String], Never>(_homeObjects)

    func homeObjectId(spaceId: String) -> String? {
        _homeObjects[spaceId]
    }

    func setHomeObjectId(spaceId: String, objectId: String?) {
        _homeObjects[spaceId] = objectId
    }

    func homeObjectIdPublisher(spaceId: String) -> AnyPublisher<String?, Never> {
        homeObjectsSubject
            .map { $0[spaceId] }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    // MARK: - Cleanup
    func cleanStateAfterLogout() {
        showUnstableMiddlewareError = true
        lastOpenedScreen = nil
        _homeObjects = [:]
    }
    
}
