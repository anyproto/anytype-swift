import Foundation

enum HomeWidgetsState {
    case readwrite
    case readonly
    case editWidgets
}

extension HomeWidgetsState {
    var isEditWidgets: Bool {
        self == .editWidgets
    }
    
    var isReadWrite: Bool {
        self == .readwrite
    }
    
    var isReadOnly: Bool {
        self == .readonly
    }
}

extension HomeWidgetsState {
    var analyticsWidgetContext: AnalyticsWidgetContext {
        isEditWidgets ? .editor : .home
    }
}
