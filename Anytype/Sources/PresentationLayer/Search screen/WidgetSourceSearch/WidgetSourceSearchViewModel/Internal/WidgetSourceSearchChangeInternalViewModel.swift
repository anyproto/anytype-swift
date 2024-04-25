import Foundation
import Services

final class WidgetSourceSearchChangeInternalViewModel: WidgetSourceSearchInternalViewModelProtocol {
    
    // MARK: - DI
    
    @Injected(\.blockWidgetService)
    private var blockWidgetService: BlockWidgetServiceProtocol
    @Injected(\.documentService)
    private var documentService: OpenedDocumentsProviderProtocol
    
    private lazy var document: BaseDocumentProtocol = {
        documentService.document(objectId: widgetObjectId)
    }()
    private let widgetObjectId: String
    private let widgetId: String
    private let context: AnalyticsWidgetContext
    private let onFinish: () -> Void
    
    init(
        widgetObjectId: String,
        widgetId: String,
        context: AnalyticsWidgetContext,
        onFinish: @escaping () -> Void
    ) {
        self.widgetObjectId = widgetObjectId
        self.widgetId = widgetId
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
