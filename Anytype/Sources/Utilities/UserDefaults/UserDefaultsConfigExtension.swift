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
    @UserDefault("UserData.LastOpenedViewType", defaultValue: nil)
    private static var _lastOpenedViewType: String?
    
    private static var _screenDataFromLastSessionInitialized = false
    private static var _screenDataFromLastSession: EditorScreenData?
    static var screenDataFromLastSession: EditorScreenData? {
        initializeScreenDataFromLastSession()
        return _screenDataFromLastSession
    }
    
    static func storeOpenedScreenData(_ data: EditorScreenData?) {
        initializeScreenDataFromLastSession()
        _lastOpenedPageId = data?.pageId
        _lastOpenedViewType = data?.type.rawValue
    }
    
    private static func initializeScreenDataFromLastSession() {
        guard !_screenDataFromLastSessionInitialized else { return }
        _screenDataFromLastSessionInitialized = true
        
        guard let type = _lastOpenedViewType.flatMap ({ EditorViewType(rawValue: $0) }) else { return }
        guard let pageId = _lastOpenedPageId else { return }
                
        _screenDataFromLastSession = EditorScreenData(pageId: pageId, type: type)
    }
    
    // MARK: - Default object type
    @UserDefault("UserData.DefaultObjectType", defaultValue: "")
    static var defaultObjectType: String
    
    // MARK: - Wallpaper    
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
