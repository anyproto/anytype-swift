import Foundation
import BlocksModels
import Combine

final class SetsWidgetInternalViewModel: WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let setsSubscriptionService: SetsSubscriptionServiceProtocol
    private let context: WidgetInternalViewModelContext
    
    // MARK: - State
    
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = Loc.sets
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    
    init(setsSubscriptionService: SetsSubscriptionServiceProtocol, context: WidgetInternalViewModelContext) {
        self.setsSubscriptionService = setsSubscriptionService
        self.context = context
    }
    
    // MARK: - WidgetInternalViewModelProtocol
    
    func startHeaderSubscription() {}
    
    func stopHeaderSubscription() {}
    
    func startContentSubscription() {
        setsSubscriptionService.startSubscription(
            objectLimit: context.maxItems,
            update: { [weak self] _, update in
                var details = self?.details ?? []
                details.applySubscriptionUpdate(update)
                self?.details = details
            }
        )
    }
    
    func stopContentSubscription() {
        setsSubscriptionService.stopSubscription()
    }
    
    func screenData() -> EditorScreenData? {
        return EditorScreenData(pageId: "", type: .sets)
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .sets
    }
}
