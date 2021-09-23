import AnytypeCore

extension UserDefaultsConfig {
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
