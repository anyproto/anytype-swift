import Services
import AnytypeCore

extension AnytypeWidgetId {
    static var availableWidgets: [AnytypeWidgetId] {
        var widgets: [AnytypeWidgetId] = AnytypeWidgetId.allCases
        
        if !FeatureFlags.chatInDataSpace {
            widgets.removeAll { $0 == .chat }
        }
        
        return widgets
    }
}
