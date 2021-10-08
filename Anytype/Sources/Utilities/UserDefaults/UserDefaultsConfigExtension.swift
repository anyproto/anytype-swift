import AnytypeCore
import BlocksModels

extension UserDefaultsConfig {
    static func cleanStateAfterLogout() {
        usersIdKey = ""
        lastOpenedPageId = nil
        _selectedTab = nil
    }
    
    @UserDefault("UserData.LastOpenedPageId", defaultValue: nil)
    static var lastOpenedPageId: String?
    
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
}
