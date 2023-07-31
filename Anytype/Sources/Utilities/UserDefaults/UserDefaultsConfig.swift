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
    
    @UserDefault("UserData.DefaultObjectType", defaultValue: ObjectType.emptyType)
    static var defaultObjectType: ObjectType {
        didSet {
            AnytypeAnalytics.instance().logDefaultObjectTypeChange(defaultObjectType.analyticsType)
        }
    }
    
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
    
    @UserDefault("UserData.Wallpaper", defaultValue: nil)
    private static var _wallpaper: Data?
    
    private static var wallpaperSubject = CurrentValueSubject<BackgroundType, Never>(wallpaper)
    static var wallpaperPublisher: AnyPublisher<BackgroundType, Never> { wallpaperSubject.eraseToAnyPublisher() }
    
    static var wallpaper: BackgroundType {
        get {
            guard let rawWallpaper = _wallpaper else { return .default }
            if let wallpaper = try? JSONDecoder().decode(BackgroundType.self, from: rawWallpaper) {
                return wallpaper
            }
            
            return .default
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else {
                anytypeAssertionFailure("Cannot encode", info: ["wallpaperId": "\(newValue)"])
                return
            }
            _wallpaper = encoded
            wallpaperSubject.send(newValue)
        }
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
