import Foundation
import Services

final class WidgetSourceSearchSelectInternalViewModel: WidgetSourceSearchInternalViewModelProtocol {
    
    private let onSelectClosure: (_ source: WidgetSource) -> Void
    private let context: AnalyticsWidgetContext
    
    init(context: AnalyticsWidgetContext, onSelect: @escaping (_ source: WidgetSource) -> Void) {
        self.context = context
        self.onSelectClosure = onSelect
    }
    
    // MARK: - WidgetSourceSearchInternalViewModelProtocol
    
    func onSelect(source: WidgetSource) {
        AnytypeAnalytics.instance().logChangeWidgetSource(source: source.analyticsSource, route: .addWidget, context: context)
        onSelectClosure(source)
    }
}
