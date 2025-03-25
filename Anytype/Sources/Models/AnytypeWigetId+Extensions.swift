import Services
import AnytypeCore

extension AnytypeWidgetId {
    static var availableWidgets: [AnytypeWidgetId] {
        var widgets: [AnytypeWidgetId] = AnytypeWidgetId.allCases
                
        if !FeatureFlags.binWidgetFromLibrary {
            widgets.removeAll { $0 == .bin }
        }
        
        if !FeatureFlags.allContentWidgets {
            let removeWidgets: [AnytypeWidgetId] = [.pages, .lists, .media, .bookmarks, .files]
            widgets.removeAll { removeWidgets.contains($0) }
        }
        
        if FeatureFlags.objectTypeWidgets {
            let removeWidgets: [AnytypeWidgetId] = [.sets, .collections]
            widgets.removeAll { removeWidgets.contains($0) }
        }
        
        return widgets
    }
}
