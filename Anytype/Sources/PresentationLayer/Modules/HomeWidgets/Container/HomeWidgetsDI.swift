import Foundation

extension Container {
    var homeWidgetsRecentStateManager: Factory<any HomeWidgetsRecentStateManagerProtocol> {
        self { HomeWidgetsRecentStateManager() }
    }
    
    var widgetActionsViewCommonMenuProvider: Factory<any WidgetActionsViewCommonMenuProviderProtocol> {
        self { WidgetActionsViewCommonMenuProvider() }.shared
    }
}
