import Foundation
import Services
import Combine

@MainActor
final class CollectionsWidgetInternalViewModel: CommonWidgetInternalViewModel, WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let subscriptionService: CollectionsSubscriptionServiceProtocol
    
    // MARK: - State
    
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = Loc.collections
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    
    init(
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol,
        subscriptionService: CollectionsSubscriptionServiceProtocol
    ) {
        self.subscriptionService = subscriptionService
        super.init(widgetBlockId: widgetBlockId, widgetObject: widgetObject)
    }
    
    // MARK: - WidgetInternalViewModelProtocol
    
    override func startContentSubscription() async {
        await super.startContentSubscription()
        await updateSubscription()
    }
    
    override func stopContentSubscription() async {
        await super.stopContentSubscription()
        await subscriptionService.stopSubscription()
    }
    
    func screenData() -> EditorScreenData? {
        return .collections
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .collections
    }
    
    // MARK: - CommonWidgetInternalViewModel oveerides
    
    override func widgetInfoUpdated() {
        Task {
            await updateSubscription()
        }
    }
    
    // MARK: - Private func
    
    private func updateSubscription() async {
        guard let widgetInfo, contentIsAppear else { return }
        await subscriptionService.startSubscription(objectLimit: widgetInfo.fixedLimit) { [weak self] details in
            self?.details = details
        }
    }
}
