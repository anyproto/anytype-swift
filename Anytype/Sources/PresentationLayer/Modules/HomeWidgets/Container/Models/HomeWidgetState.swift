import Foundation

enum HomeWidgetsState {
    case readwrite
    case readonly
}

extension HomeWidgetsState {
    var isReadWrite: Bool {
        self == .readwrite
    }
    
    var isReadOnly: Bool {
        self == .readonly
    }
}

extension HomeWidgetsState {
    var analyticsWidgetContext: AnalyticsWidgetContext {
        .home
    }
}
