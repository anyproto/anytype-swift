import Foundation

extension Container {
    var homeWidgetsRecentStateManager: Factory<any HomeWidgetsRecentStateManagerProtocol> {
        self { HomeWidgetsRecentStateManager() }
    }
}
