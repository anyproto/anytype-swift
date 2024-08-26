import Foundation
import AnytypeCore

enum RecentWidgetType: String {
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
    
    func editorScreenData(spaceId: String) -> EditorScreenData {
        switch self {
        case .recentEdit:
            return .recentEdit(spaceId: spaceId)
        case .recentOpen:
            return .recentOpen(spaceId: spaceId)
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
