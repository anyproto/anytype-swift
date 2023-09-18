import Foundation
import AnytypeCore

enum RecentWidgetType {
    case recentEdit
    case recentOpen
}

// MARK: - View adopt

extension RecentWidgetType {
    var title: String {
        switch self {
        case .recentEdit:
            return Loc.Widgets.Library.RecentlyEdited.name
        case .recentOpen:
            return Loc.Widgets.Library.RecentlyOpened.name
        }
    }
    
    var editorScreenData: EditorScreenData {
        switch self {
        case .recentEdit:
            return .recentEdit
        case .recentOpen:
            return .recentOpen
        }
    }
    
    var analyticsSource: AnalyticsWidgetSource {
        switch self {
        case .recentEdit:
            return .recent
        case .recentOpen:
            return .recentOpen
        }
    }
}
