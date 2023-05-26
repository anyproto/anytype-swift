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
    
    @UserDefault("UserData.DefaultObjectType", defaultValue: ObjectType.fallbackType)
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
        _screenDataFromLastSession = nil
        storeOpenedScreenData(nil)
    }
    
}

// MARK: - Opened Page id

extension UserDefaultsConfig {
    
    @UserDefault("UserData.LastOpenedPageId", defaultValue: nil)
    private static var _lastOpenedPageId: String?
    @UserDefault("UserData.LastOpenedViewType", defaultValue: nil)
    private static var _lastOpenedViewType: String?
    @UserDefault("UserData.LastOpenedBlockId", defaultValue: nil)
    private static var _lastOpenedBlockId: String?
    @UserDefault("UserData.LastOpenedTargetObjectID", defaultValue: nil)
    private static var _lastOpenedTargetObjectID: String?
    
    private static var _screenDataFromLastSessionInitialized = false
    private static var _screenDataFromLastSession: EditorScreenData?
    static var screenDataFromLastSession: EditorScreenData? {
        initializeScreenDataFromLastSession()
        return _screenDataFromLastSession
    }
    
    static func storeOpenedScreenData(_ data: EditorScreenData?) {
        initializeScreenDataFromLastSession()
        _lastOpenedPageId = data?.pageId
        
        switch data?.type {
        case .page, .favorites, .recent, .sets, .collections, .bin:
            _lastOpenedViewType = data?.type.rawValue
            _lastOpenedBlockId = nil
            _lastOpenedTargetObjectID = nil
        case let .set(blockId, targetObjectId):
            _lastOpenedViewType = data?.type.rawValue
            _lastOpenedBlockId = blockId
            _lastOpenedTargetObjectID = targetObjectId
        case .none:
            _lastOpenedViewType = nil
            _lastOpenedBlockId = nil
            _lastOpenedTargetObjectID = nil
        }
    }
    
    private static func initializeScreenDataFromLastSession() {
        guard !_screenDataFromLastSessionInitialized else { return }
        _screenDataFromLastSessionInitialized = true
        
        guard let type = _lastOpenedViewType.flatMap ({
            EditorViewType(
                rawValue: $0,
                blockId: _lastOpenedBlockId,
                targetObjectID: _lastOpenedTargetObjectID
            )
        }) else { return }
        
        guard let pageId = _lastOpenedPageId else { return }
                
        _screenDataFromLastSession = EditorScreenData(pageId: pageId, type: type)
    }
    
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
                anytypeAssertionFailure("Cannot encode \(newValue)", domain: .userDefaults)
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
