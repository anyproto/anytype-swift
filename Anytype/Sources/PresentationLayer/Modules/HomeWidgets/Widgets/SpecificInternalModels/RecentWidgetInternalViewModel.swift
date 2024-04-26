import Foundation
import Services
import Combine

@MainActor
final class RecentWidgetInternalViewModel: CommonWidgetInternalViewModel, WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let type: RecentWidgetType
    private let recentSubscriptionService: RecentSubscriptionServiceProtocol
    
    // MARK: - State
    
    @Published private var details: [ObjectDetails]?
    @Published private var name: String
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    
    init(
        type: RecentWidgetType,
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol,
        recentSubscriptionService: RecentSubscriptionServiceProtocol
    ) {
        self.type = type
        self.name = type.title
        self.recentSubscriptionService = recentSubscriptionService
        super.init(widgetBlockId: widgetBlockId, widgetObject: widgetObject)
    }
    
    // MARK: - WidgetInternalViewModelProtocol
    
    override func startContentSubscription() async {
        await super.startContentSubscription()
        await updateSubscription()
    }
    
    override func stopContentSubscription() async {
        await super.stopContentSubscription()
        await recentSubscriptionService.stopSubscription()
    }
    
    func screenData() -> EditorScreenData? {
        return type.editorScreenData
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return type.analyticsSource
    }
    
    // MARK: - CommonWidgetInternalViewModel oveerides
    
    override func widgetInfoUpdated() {
        super.widgetInfoUpdated()
        Task {
            await updateSubscription()
        }
    }
    
    // MARK: - Private func
    
    private func updateSubscription() async {
        guard let widgetInfo, contentIsAppear else { return }
        await recentSubscriptionService.startSubscription(
            type: type,
            objectLimit: widgetInfo.fixedLimit,
            update: { [weak self] details in
                self?.details = details
            }
        )
    }
}
