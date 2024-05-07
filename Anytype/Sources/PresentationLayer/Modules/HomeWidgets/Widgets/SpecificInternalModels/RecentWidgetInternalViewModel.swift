import Foundation
import Services
import Combine

@MainActor
final class RecentWidgetInternalViewModel: WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let type: RecentWidgetType
    private let widgetBlockId: String
    private let widgetObject: BaseDocumentProtocol
    
    @Injected(\.recentSubscriptionService)
    private var recentSubscriptionService: RecentSubscriptionServiceProtocol
    
    // MARK: - State
    
    @Published private var details: [ObjectDetails]?
    @Published private var name: String
    private var subscriptions = [AnyCancellable]()
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    
    init(
        type: RecentWidgetType,
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol
    ) {
        self.type = type
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.name = type.title
    }
    
    // MARK: - WidgetInternalViewModelProtocol
    
    func startContentSubscription() async {
        widgetObject.blockWidgetInfoPublisher(widgetBlockId: widgetBlockId)
            .receiveOnMain()
            .sink { [weak self] widgetInfo in
                guard let self else { return }
                Task {
                    await self.updateSubscription(widgetInfo: widgetInfo)
                }
            }
            .store(in: &subscriptions)
    }
    
    func startHeaderSubscription() {}
    
    func screenData() -> EditorScreenData? {
        return type.editorScreenData
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return type.analyticsSource
    }
    
    // MARK: - Private func
    
    private func updateSubscription(widgetInfo: BlockWidgetInfo) async {
        await recentSubscriptionService.startSubscription(
            type: type,
            objectLimit: widgetInfo.fixedLimit,
            update: { [weak self] details in
                self?.details = details
            }
        )
    }
}
