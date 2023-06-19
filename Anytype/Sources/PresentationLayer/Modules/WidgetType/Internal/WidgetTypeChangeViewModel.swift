import Foundation
import Services
import Combine

final class WidgetTypeChangeViewModel: WidgetTypeInternalViewModelProtocol {
    
    private let widgetObject: BaseDocumentProtocol
    private let widgetId: String
    private let blockWidgetService: BlockWidgetServiceProtocol
    private let context: AnalyticsWidgetContext
    private let onFinish: () -> Void
    private var subscriptions: [AnyCancellable] = []
    
    @Published private var state: WidgetTypeState?
    var statePublisher: AnyPublisher<WidgetTypeState?, Never> { $state.eraseToAnyPublisher() }
    
    init(
        widgetObjectId: String,
        widgetId: String,
        blockWidgetService: BlockWidgetServiceProtocol,
        documentService: DocumentServiceProtocol,
        context: AnalyticsWidgetContext,
        onFinish: @escaping () -> Void
    ) {
        self.widgetObject = documentService.document(objectId: widgetObjectId)
        self.widgetId = widgetId
        self.blockWidgetService = blockWidgetService
        self.context = context
        self.onFinish = onFinish
        
        widgetObject.syncPublisher.sink { [weak self] in
            guard let info = self?.widgetObject.widgetInfo(blockId: widgetId) else { return }
            self?.state = WidgetTypeState(source: info.source, layout: info.block.layout)
        }
        .store(in: &subscriptions)
    }
    
    // MARK: - WidgetTypeInternalViewModelProtocol
    
    func onTap(layout: BlockWidget.Layout) {
        guard let source = state?.source else { return }
        
        AnytypeAnalytics.instance().logChangeWidgetLayout(source: source.analyticsSource, layout: layout, route: .inner, context: context)
        
        Task { @MainActor in
            try? await blockWidgetService.replaceWidgetBlock(
                contextId: widgetObject.objectId,
                widgetBlockId: widgetId,
                sourceId: source.sourceId,
                layout: layout
            )
            onFinish()
        }
    }
}
