import Foundation
import Services
import AnytypeCore

final class WidgetSourceSearchSelectInternalViewModel: WidgetSourceSearchInternalViewModelProtocol {
    
    private let onSelectClosure: (_ source: WidgetSource, _ openObject: ScreenData?) -> Void
    private let data: WidgetSourceSearchModuleModel
    
    @Injected(\.blockWidgetService)
    private var blockWidgetService: any BlockWidgetServiceProtocol
    
    init(data: WidgetSourceSearchModuleModel, onSelect: @escaping (_ source: WidgetSource, _ openObject: ScreenData?) -> Void) {
        self.data = data
        self.onSelectClosure = onSelect
    }
    
    // MARK: - WidgetSourceSearchInternalViewModelProtocol
    
    func onSelect(source: WidgetSource, openObject: ScreenData?) {
        AnytypeAnalytics.instance().logChangeWidgetSource(source: source.analyticsSource, route: .addWidget, context: data.context)
        
        let layout = source.availableWidgetLayout.first ?? .link
        Task { @MainActor in
            try await blockWidgetService.createWidgetBlock(
                contextId: data.widgetObjectId,
                sourceId: source.sourceId,
                layout: layout,
                limit: layout.limits.first ?? 0,
                position: data.position
            )
            AnytypeAnalytics.instance().logAddWidget(context: data.context, createType: .manual)
        }
        
        onSelectClosure(source, openObject)
    }
}
