import Foundation
import BlocksModels
import Combine

final class RecentWidgetInternalViewModel: WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let recentSubscriptionService: RecentSubscriptionServiceProtocol
    private let context: WidgetInternalViewModelContext
    
    // MARK: - State
    
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = Loc.recent
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    
    init(recentSubscriptionService: RecentSubscriptionServiceProtocol, context: WidgetInternalViewModelContext) {
        self.recentSubscriptionService = recentSubscriptionService
        self.context = context
    }
    
    // MARK: - WidgetInternalViewModelProtocol
    
    func startHeaderSubscription() {}
    
    func stopHeaderSubscription() {}
    
    func startContentSubscription() {
        recentSubscriptionService.startSubscription(
            objectLimit: context.maxItems,
            update: { [weak self] _, update in
                var details = self?.details ?? []
                details.applySubscriptionUpdate(update)
                self?.details = details
            }
        )
    }
    
    func stopContentSubscription() {
        recentSubscriptionService.stopSubscription()
    }
    
    func screenData() -> EditorScreenData? {
        return EditorScreenData(pageId: "", type: .recent)
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .recent
    }
}
