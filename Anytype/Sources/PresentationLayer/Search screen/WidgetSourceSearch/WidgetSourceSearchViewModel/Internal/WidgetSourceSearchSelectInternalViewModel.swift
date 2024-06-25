import Foundation
import Services
import AnytypeCore

final class WidgetSourceSearchSelectInternalViewModel: WidgetSourceSearchInternalViewModelProtocol {
    
    private let onSelectClosure: (_ source: WidgetSource) -> Void
    private let data: WidgetSourceSearchModuleModel
    
    @Injected(\.blockWidgetService)
    private var blockWidgetService: BlockWidgetServiceProtocol
    
    init(data: WidgetSourceSearchModuleModel, onSelect: @escaping (_ source: WidgetSource) -> Void) {
        self.data = data
        self.onSelectClosure = onSelect
    }
    
    // MARK: - WidgetSourceSearchInternalViewModelProtocol
    
    func onSelect(source: WidgetSource) {
        AnytypeAnalytics.instance().logChangeWidgetSource(source: source.analyticsSource, route: .addWidget, context: data.context)
        
        if FeatureFlags.widgetCreateWithoutType {
            let layout = source.availableWidgetLayout.first ?? .link
            Task { @MainActor in
                try? await blockWidgetService.createWidgetBlock(
                    contextId: data.widgetObjectId,
                    sourceId: source.sourceId,
                    layout: layout,
                    limit: layout.limits.first ?? 0,
                    position: data.position
                )
            }
        }
        
        onSelectClosure(source)
        
    }
}
