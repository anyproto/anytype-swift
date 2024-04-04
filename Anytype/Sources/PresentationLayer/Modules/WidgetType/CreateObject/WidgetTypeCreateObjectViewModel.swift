import Foundation
import Services
import Combine

@MainActor
final class WidgetTypeCreateObjectViewModel: ObservableObject {
    
    @Injected(\.blockWidgetService)
    private var blockWidgetService: BlockWidgetServiceProtocol
    private let data: WidgetTypeCreateData
    
    @Published var rows: [WidgetTypeRowView.Model] = []
    
    init(data: WidgetTypeCreateData) {
        self.data = data
        setupView()
    }
    
    // MARK: - Private
    
    private func setupView() {
        let availableLayouts = data.source.availableWidgetLayout
        rows = availableLayouts.map { layout in
            return WidgetTypeRowView.Model(
                layout: layout,
                isSelected: false,
                onTap: { [weak self] in
                    self?.onTap(layout: layout)
            })
        }
    }
    
    private func onTap(layout: BlockWidget.Layout) {
        AnytypeAnalytics.instance().logChangeWidgetLayout(
            source: data.source.analyticsSource,
            layout: layout,
            route: .addWidget,
            context: data.context
        )
        
        Task { @MainActor in
            try? await blockWidgetService.createWidgetBlock(
                contextId: data.widgetObjectId,
                sourceId: data.source.sourceId,
                layout: layout,
                limit: layout.limits.first ?? 0,
                position: data.position
            )
            data.onFinish()
        }
    }
}
