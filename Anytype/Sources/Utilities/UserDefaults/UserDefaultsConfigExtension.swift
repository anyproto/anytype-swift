import AnytypeCore
import BlocksModels

extension UserDefaultsConfig {
    
    // MARK: - Selected Tab
    @UserDefault("UserData.SelectedTab", defaultValue: nil)
    private static var _selectedTab: String?
    
    static var selectedTab: HomeTabsView.Tab {
        get {
            _selectedTab.flatMap { HomeTabsView.Tab(rawValue: $0) } ?? HomeTabsView.Tab.favourites
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
}
