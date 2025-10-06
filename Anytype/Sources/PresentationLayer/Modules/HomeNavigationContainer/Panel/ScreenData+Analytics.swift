import Foundation

protocol HomeClinkNavBarAddMenuRouteProvider {
    var clickNavBarAddMenuRoute: ClickNavBarAddMenuRoute { get }
}

extension EditorScreenData: HomeClinkNavBarAddMenuRouteProvider {
    var clickNavBarAddMenuRoute: ClickNavBarAddMenuRoute {
        switch self {
        case .pinned:
            return .screenFavorites
        case .recentEdit:
            return .screenRecentEdit
        case .recentOpen:
            return .screenRecentOpen
        case .bin:
            return .screenBin
        case .page, .list:
            return .screenObject
        case .date:
            return .screenDate
        case .type:
            return .screenType
        case .allObjects:
            return .screenAllObjects
        }
    }
}
extension HomeWidgetData: HomeClinkNavBarAddMenuRouteProvider {
    var clickNavBarAddMenuRoute: ClickNavBarAddMenuRoute { .screenWidget }
}
