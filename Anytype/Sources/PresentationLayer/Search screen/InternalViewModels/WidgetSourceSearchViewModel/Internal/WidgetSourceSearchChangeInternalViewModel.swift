import Foundation
import Services

final class WidgetSourceSearchChangeInternalViewModel: WidgetSourceSearchInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let document: BaseDocumentProtocol
    private let widgetId: String
    private let blockWidgetService: BlockWidgetServiceProtocol
    private let context: AnalyticsWidgetContext
    private let onFinish: () -> Void
    
    init(
        widgetObjectId: String,
        widgetId: String,
        documentService: OpenedDocumentsProviderProtocol,
        blockWidgetService: BlockWidgetServiceProtocol,
        context: AnalyticsWidgetContext,
        onFinish: @escaping () -> Void
    ) {
        self.document = documentService.document(objectId: widgetObjectId)
        self.widgetId = widgetId
        self.blockWidgetService = blockWidgetService
        self.context = context
        self.onFinish = onFinish
    }

    // MARK: - WidgetSourceSearchInternalViewModelProtocol
    
    func onSelect(source: WidgetSource) {
        guard let info = document.widgetInfo(blockId: widgetId) else { return }
        
        AnytypeAnalytics.instance().logChangeWidgetSource(source: source.analyticsSource, route: .inner, context: context)
        
        guard info.source != source else {
            onFinish()
            return
        }
        
        Task { @MainActor in
            try? await blockWidgetService.setSourceId(
                contextId: document.objectId,
                widgetBlockId: widgetId,
                sourceId: source.sourceId
            )
            onFinish()
        }
    }
}
