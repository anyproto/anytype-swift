import Foundation
import BlocksModels

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
        documentService: DocumentServiceProtocol,
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
        guard let info = document.widgetInfo(blockId: widgetId),
              let layout = layoutFor(source: source, oldLayout: info.block.layout) else { return }
        
        AnytypeAnalytics.instance().logChangeWidgetSource(source: source.analyticsSource, route: .inner, context: context)
        
        guard info.source != source else {
            onFinish()
            return
        }
        
        Task { @MainActor in
            try? await blockWidgetService.replaceWidgetBlock(
                contextId: document.objectId,
                widgetBlockId: widgetId,
                sourceId: source.sourceId,
                layout: layout
            )
            onFinish()
        }
    }
    
    private func layoutFor(source: WidgetSource, oldLayout: BlockWidget.Layout) -> BlockWidget.Layout? {
        let availableLayout = source.availableWidgetLayout
        guard !availableLayout.contains(oldLayout) else {
            return oldLayout
        }
        
        let fallbackValue = fallbackValue(for: source)
        if availableLayout.contains(fallbackValue) {
            return fallbackValue
        }
        
        return availableLayout.first
    }
    
    private func fallbackValue(for source: WidgetSource) -> BlockWidget.Layout {
        switch source {
        case .object:
            return .link
        case .library:
            return .list
        }
    }
}
