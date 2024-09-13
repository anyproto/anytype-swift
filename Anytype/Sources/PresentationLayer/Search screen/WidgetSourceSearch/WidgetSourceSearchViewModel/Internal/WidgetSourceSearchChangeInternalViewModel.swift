import Foundation
import Services

final class WidgetSourceSearchChangeInternalViewModel: WidgetSourceSearchInternalViewModelProtocol {
    
    // MARK: - DI
    
    @Injected(\.blockWidgetService)
    private var blockWidgetService: any BlockWidgetServiceProtocol
    @Injected(\.documentService)
    private var documentService: any OpenedDocumentsProviderProtocol
    
    private lazy var document: any BaseDocumentProtocol = {
        documentService.document(objectId: widgetObjectId)
    }()
    private let widgetObjectId: String
    private let widgetId: String
    private let context: AnalyticsWidgetContext
    private let onFinish: (_ openObject: EditorScreenData?) -> Void
    
    init(
        widgetObjectId: String,
        widgetId: String,
        context: AnalyticsWidgetContext,
        onFinish: @escaping (_ openObject: EditorScreenData?) -> Void
    ) {
        self.widgetObjectId = widgetObjectId
        self.widgetId = widgetId
        self.context = context
        self.onFinish = onFinish
    }

    // MARK: - WidgetSourceSearchInternalViewModelProtocol
    
    func onSelect(source: WidgetSource, openObject: EditorScreenData?) {
        guard let info = document.widgetInfo(blockId: widgetId) else { return }
        
        AnytypeAnalytics.instance().logChangeWidgetSource(source: source.analyticsSource, route: .inner, context: context)
        
        guard info.source != source else {
            onFinish(openObject)
            return
        }
        
        Task { @MainActor in
            try? await blockWidgetService.setSourceId(
                contextId: document.objectId,
                widgetBlockId: widgetId,
                sourceId: source.sourceId
            )
            onFinish(openObject)
        }
    }
}
