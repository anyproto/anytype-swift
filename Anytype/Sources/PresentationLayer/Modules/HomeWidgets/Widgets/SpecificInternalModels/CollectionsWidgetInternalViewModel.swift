import Foundation
import Services
import Combine

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
    
    override func startContentSubscription() {
        super.startContentSubscription()
        updateSubscription()
    }
    
    override func stopContentSubscription() {
        super.stopContentSubscription()
        subscriptionService.stopSubscription()
    }
    
    func screenData() -> EditorScreenData? {
        return .collections
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .collections
    }
    
    // MARK: - CommonWidgetInternalViewModel oveerides
    
    override func widgetInfoUpdated() {
        updateSubscription()
    }
    
    // MARK: - Private func
    
    private func updateSubscription() {
        guard let widgetInfo, contentIsAppear else { return }
        subscriptionService.startSubscription(
            objectLimit: widgetInfo.fixedLimit,
            update: { [weak self] _, update in
                var details = self?.details ?? []
                details.applySubscriptionUpdate(update)
                self?.details = details
            }
        )
    }
}
