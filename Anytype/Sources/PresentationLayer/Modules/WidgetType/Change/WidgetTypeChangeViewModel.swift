import Foundation
import Services
import Combine

@MainActor
final class WidgetTypeChangeViewModel: ObservableObject {
    
    @Injected(\.blockWidgetService)
    private var blockWidgetService: any BlockWidgetServiceProtocol
    @Injected(\.openedDocumentProvider)
    private var documentService: any OpenedDocumentsProviderProtocol
    
    private let data: WidgetTypeChangeData
    
    private lazy var widgetObject: any BaseDocumentProtocol = {
        documentService.document(objectId: data.widgetObjectId, spaceId: data.widgetSpaceId)
    }()
    
    @Published var rows: [WidgetTypeRowView.Model] = []

    init(data: WidgetTypeChangeData) {
        self.data = data
    }
    
    func startObserveDocument() async {
        for await info in widgetObject.blockWidgetInfoPublisher(widgetBlockId: data.widgetId).values {
            updateRows(info: info)
        }
    }
    
    private func updateRows(info: BlockWidgetInfo) {
        let source = info.source
        let selectedLayout = info.fixedLayout
        
        let availableLayouts = source.availableWidgetLayout
        rows = availableLayouts.map { layout in
            return WidgetTypeRowView.Model(
                layout: layout,
                isSelected: layout == selectedLayout,
                onTap: { [weak self] in
                    self?.onTap(layout: layout, source: source)
            })
        }
    }
    
    private func onTap(layout: BlockWidget.Layout, source: WidgetSource) {
        
        AnytypeAnalytics.instance().logChangeWidgetLayout(
            source: source.analyticsSource,
            layout: layout,
            route: .inner,
            context: data.context
        )
        
        Task { @MainActor in
            try? await blockWidgetService.setLayout(
                contextId: data.widgetObjectId,
                widgetBlockId: data.widgetId,
                layout: layout
            )
            data.onFinish()
        }
    }
}
