import Services
import AnytypeCore

extension AnytypeWidgetId {
    static var availableWidgets: [AnytypeWidgetId] {
        if FeatureFlags.allContentWidgets {
            AnytypeWidgetId.allCases
        } else {
            [.favorite, .sets, .collections, .recent, .recentOpen]
        }
    }
}
