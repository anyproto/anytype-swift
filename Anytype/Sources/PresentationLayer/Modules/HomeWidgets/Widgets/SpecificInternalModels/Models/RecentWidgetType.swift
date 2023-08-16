import Foundation
import AnytypeCore

enum RecentWidgetType {
    case recentEdit
    case recentOpen
}

// MARK: - View adopt

extension RecentWidgetType {
    var title: String {
        if FeatureFlags.recentEditWidget {
            switch self {
            case .recentEdit:
                return Loc.Widgets.Library.RecentlyEdited.name
            case .recentOpen:
                return Loc.Widgets.Library.RecentlyOpened.name
            }
        } else {
            return Loc.recent
        }
    }
    
    var editorScreenData: EditorScreenData {
        if FeatureFlags.recentEditWidget {
            switch self {
            case .recentEdit:
                return .recentEdit
            case .recentOpen:
                return .recentOpen
            }
        } else {
            return .recentEdit
        }
    }
    
    var analyticsSource: AnalyticsWidgetSource {
        if FeatureFlags.recentEditWidget {
            switch self {
            case .recentEdit:
                return .recent
            case .recentOpen:
                return .recentOpen
            }
        } else {
            return .recent
        }
    }
}
