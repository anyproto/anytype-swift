import Services
import AnytypeCore

extension AnytypeWidgetId {
    static var availableWidgets: [AnytypeWidgetId] {
        var widgets: [AnytypeWidgetId] = AnytypeWidgetId.allCases
                
        if !FeatureFlags.binWidgetFromLibrary {
            widgets.removeAll { $0 == .bin }
        }
        
        return widgets
    }
}
