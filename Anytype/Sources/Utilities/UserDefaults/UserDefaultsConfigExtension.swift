import AnytypeCore
import BlocksModels
import Combine

extension UserDefaultsConfig {
    static func cleanStateAfterLogout() {
        usersIdKey = ""
        _lastOpenedPageId = nil
        _selectedTab = nil
    }
    
    // MARK: - Selected Tab
    @UserDefault("UserData.SelectedTab", defaultValue: nil)
    private static var _selectedTab: String?
    
    static var selectedTab: HomeTabsView.Tab {
        get {
            let tab = _selectedTab.flatMap { HomeTabsView.Tab(rawValue: $0) } ?? .favourites
            
            if tab == .shared && !AccountConfigurationProvider.shared.config.enableSpaces {
                return .favourites
            }
            
            return tab
        }
        set {
            _selectedTab = newValue.rawValue
        }
    }
    
    // MARK: - Opened Page id
    @UserDefault("UserData.LastOpenedPageId", defaultValue: nil)
    private static var _lastOpenedPageId: String?
    
    private static var pageIdFromLastSessionInitialized = false
    private static var _pageIdFromLastSession: String?
    static var pageIdFromLastSession: BlockId? {
        initializePageIdFromLastSession()
        return _pageIdFromLastSession
    }
    
    static func storeOpenedPageId(_ pageId: BlockId?) {
        initializePageIdFromLastSession()
        _lastOpenedPageId = pageId
    }
    
    private static func initializePageIdFromLastSession() {
        guard !pageIdFromLastSessionInitialized else { return }
        _pageIdFromLastSession = _lastOpenedPageId
        pageIdFromLastSessionInitialized = true
    }
    
    // Default object type
    @UserDefault("UserData.DefaultObjectType", defaultValue: "")
    static var defaultObjectType: String
    
    // Wallpaper    
    @UserDefault("UserData.Wallpaper", defaultValue: nil)
    private static var _wallpaper: Data?
    
    static var wallpaper: BackgroundType {
        get {
            guard let rawWallpaper = _wallpaper else { return .default }
            guard let wallpaper = try? JSONDecoder().decode(BackgroundType.self, from: rawWallpaper) else {
                return .default
            }
            
            return wallpaper
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else {
                anytypeAssertionFailure("Cannot encode \(newValue)")
                return
            }
            _wallpaper = encoded
        }
    }
}
