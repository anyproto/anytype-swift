import AnytypeCore
import Services
import Combine
import SwiftUI

protocol UserDefaultsStorageProtocol {
    var showUnstableMiddlewareError: Bool { get set }
    var usersId: String { get set }
    var currentVersionOverride: String { get set }
    var installedAtDate: Date? { get set }
    var analyticsUserConsent: Bool { get set }
    var defaultObjectTypes: [String: String] { get set }
    var rowsPerPageInSet: Int { get set }
    var rowsPerPageInGroupedSet: Int { get set }
    var userInterfaceStyle: UIUserInterfaceStyle { get set }
    
    func saveLastOpenedScreen(spaceId: String, screen: EditorScreenData?)
    func getLastOpenedScreen(spaceId: String) -> EditorScreenData?
    
    func wallpaperPublisher(spaceId: String) -> AnyPublisher<BackgroundType, Never>
    func wallpaper(spaceId: String) -> BackgroundType
    func setWallpaper(spaceId: String, wallpaper: BackgroundType)
    
    func cleanStateAfterLogout()
}

final class UserDefaultsStorage: UserDefaultsStorageProtocol {
    @UserDefault("showUnstableMiddlewareError", defaultValue: true)
    var showUnstableMiddlewareError: Bool
    
    @UserDefault("userId", defaultValue: "")
    var usersId: String
    
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
    
    // MARK: - Last opened screens
    @UserDefault("UserData.LastOpenedScreens", defaultValue: [:])
    private var lastOpenedScreens: [String: EditorScreenData]
    
    func saveLastOpenedScreen(spaceId: String, screen: EditorScreenData?) {
        lastOpenedScreens[spaceId] = screen
    }
    
    func getLastOpenedScreen(spaceId: String) -> EditorScreenData? {
        lastOpenedScreens[spaceId]
    }
    
    // MARK: - Wallpaper
    @UserDefault("UserData.Wallpapers", defaultValue: [:])
    private var _wallpapers: [String: BackgroundType] {
        didSet { wallpapersSubject.send(_wallpapers) }
    }
    
    private lazy var wallpapersSubject = CurrentValueSubject<[String: BackgroundType], Never>(_wallpapers)
    func wallpaperPublisher(spaceId: String) -> AnyPublisher<BackgroundType, Never> {
        return wallpapersSubject
            .compactMap { items -> BackgroundType in
                return items[spaceId] ?? .default
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func wallpaper(spaceId: String) -> BackgroundType {
        return _wallpapers[spaceId] ?? .default
    }
    
    func setWallpaper(spaceId: String, wallpaper: BackgroundType) {
        _wallpapers[spaceId] = wallpaper
    }
    
    // MARK: - Cleanup
    func cleanStateAfterLogout() {
        usersId = ""
        showUnstableMiddlewareError = true
        lastOpenedScreens = [:]
    }
    
}
