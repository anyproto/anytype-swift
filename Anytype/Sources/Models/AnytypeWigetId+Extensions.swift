import Services
import AnytypeCore

extension AnytypeWidgetId {
    static var availableWidgets: [AnytypeWidgetId] {
        let widgets: [AnytypeWidgetId]
        if FeatureFlags.allContentWidgets {
            widgets = AnytypeWidgetId.allCases
        } else {
            widgets = [.favorite, .sets, .collections, .recent, .recentOpen]
        }
        return FeatureFlags.objectTypeWidgets ? widgets.filter { $0 != .collections && $0 != .sets } : widgets
    }
}
