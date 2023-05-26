import Foundation
import Services
import Combine

final class WidgetTypeCreateObjectViewModel: WidgetTypeInternalViewModelProtocol {
    
    private let widgetObjectId: String
    private let position: WidgetPosition
    private let blockWidgetService: BlockWidgetServiceProtocol
    private let context: AnalyticsWidgetContext
    private let onFinish: () -> Void
    
    @Published private var state: WidgetTypeState?
    var statePublisher: AnyPublisher<WidgetTypeState?, Never> { $state.eraseToAnyPublisher() }
    
    init(
        widgetObjectId: String,
        source: WidgetSource,
        position: WidgetPosition,
        blockWidgetService: BlockWidgetServiceProtocol,
        context: AnalyticsWidgetContext,
        onFinish: @escaping () -> Void
    ) {
        self.widgetObjectId = widgetObjectId
        self.position = position
        self.blockWidgetService = blockWidgetService
        self.context = context
        self.onFinish = onFinish
        self.state = WidgetTypeState(source: source, layout: nil)
    }
    
    // MARK: - WidgetTypeInternalViewModelProtocol
    
    func onTap(layout: BlockWidget.Layout) {
        guard let source = state?.source else { return }
        
        AnytypeAnalytics.instance().logChangeWidgetLayout(source: source.analyticsSource, layout: layout, route: .addWidget, context: context)
        
        Task { @MainActor in
            try? await blockWidgetService.createWidgetBlock(
                contextId: widgetObjectId,
                sourceId: source.sourceId,
                layout: layout,
                position: position
            )
            onFinish()
        }
    }
}
