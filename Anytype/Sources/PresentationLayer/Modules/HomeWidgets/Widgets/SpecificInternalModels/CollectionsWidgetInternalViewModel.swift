import Foundation
import BlocksModels
import Combine

final class CollectionsWidgetInternalViewModel: WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let subscriptionService: CollectionsSubscriptionServiceProtocol
    private let context: WidgetInternalViewModelContext
    
    // MARK: - State
    
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = Loc.collections
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    
    init(subscriptionService: CollectionsSubscriptionServiceProtocol, context: WidgetInternalViewModelContext) {
        self.subscriptionService = subscriptionService
        self.context = context
    }
    
    // MARK: - WidgetInternalViewModelProtocol
    
    func startHeaderSubscription() {}
    
    func stopHeaderSubscription() {}
    
    func startContentSubscription() {
        subscriptionService.startSubscription(
            objectLimit: context.maxItems,
            update: { [weak self] _, update in
                var details = self?.details ?? []
                details.applySubscriptionUpdate(update)
                self?.details = details
            }
        )
    }
    
    func stopContentSubscription() {
        subscriptionService.stopSubscription()
    }
    
    func screenData() -> EditorScreenData? {
        return EditorScreenData(pageId: "", type: .collections)
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .collections
    }
}
