import AnytypeCore
import Services
import Combine
import SwiftUI

struct UserDefaultsConfig {
    
    @UserDefault("userId", defaultValue: "")
    public static var usersId: String

    @UserDefault("App.InstalledAtDate", defaultValue: nil)
    public static var installedAtDate: Date?
    
    @UserDefault("App.AnalyticsUserConsent", defaultValue: false)
    public static var analyticsUserConsent: Bool
    
    // Key - spaceId, value - objectTypeId
    @UserDefault("UserData.DefaultObjectTypes", defaultValue: [:])
    static var defaultObjectTypes: [String: String]
    
    @UserDefault("UserData.RowsPerPageInSet", defaultValue: 50)
    static var rowsPerPageInSet: Int
    
    @UserDefault("UserData.RowsPerPageInGroupedSet", defaultValue: 20)
    static var rowsPerPageInGroupedSet: Int
    
    @UserDefault("UserData.ShowKeychainAlert", defaultValue: false)
    static var showKeychainAlert: Bool
    
}

extension UserDefaultsConfig {
    
    static func cleanStateAfterLogout() {
        usersId = ""
        lastOpenedPage = nil
    }
    
}

// MARK: - Opened Page id

extension UserDefaultsConfig {
    
    @UserDefault("UserData.LastOpenedPage", defaultValue: nil)
    static var lastOpenedPage: EditorScreenData?
    
}

// MARK: - Wallpaper

extension UserDefaultsConfig {
    
    @UserDefault("UserData.Wallpapers", defaultValue: [:])
    private static var _wallpapers: [String: BackgroundType] {
        didSet { wallpapersSubject.send(_wallpapers) }
    }
    
    private static var wallpapersSubject = CurrentValueSubject<[String: BackgroundType], Never>(_wallpapers)
    static func wallpaperPublisher(spaceId: String) -> AnyPublisher<BackgroundType, Never> {
        return wallpapersSubject
            .compactMap { items -> BackgroundType in
                return items[spaceId] ?? .default
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    static func wallpaper(spaceId: String) -> BackgroundType {
        return _wallpapers[spaceId] ?? .default
    }
    
    static func setWallpaper(spaceId: String, wallpaper: BackgroundType) {
        _wallpapers[spaceId] = wallpaper
    }
}

// MARK: - UserInterfaceStyle

extension UserDefaultsConfig {
    
    @UserDefault("UserData.UserInterfaceStyle", defaultValue: UIUserInterfaceStyle.unspecified.rawValue)
    private static var _userInterfaceStyleRawValue: Int
    
    static var userInterfaceStyle: UIUserInterfaceStyle {
        get { UIUserInterfaceStyle(rawValue: _userInterfaceStyleRawValue) ?? .unspecified }
        set {
            _userInterfaceStyleRawValue = newValue.rawValue

            AnytypeAnalytics.instance().logSelectTheme(userInterfaceStyle)
        }
    }
    
}
