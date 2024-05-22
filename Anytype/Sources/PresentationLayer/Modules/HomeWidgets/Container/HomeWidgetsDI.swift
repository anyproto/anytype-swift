import Foundation

extension Container {
    var homeWidgetsRecentStateManager: Factory<HomeWidgetsRecentStateManagerProtocol> {
        self { HomeWidgetsRecentStateManager() }
    }
}
