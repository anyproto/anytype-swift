import Foundation
import Services
import Combine

final class SetsWidgetInternalViewModel: CommonWidgetInternalViewModel, WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let setsSubscriptionService: SetsSubscriptionServiceProtocol
    
    // MARK: - State
    
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = Loc.sets
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    
    init(
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol,
        setsSubscriptionService: SetsSubscriptionServiceProtocol
    ) {
        self.setsSubscriptionService = setsSubscriptionService
        super.init(widgetBlockId: widgetBlockId, widgetObject: widgetObject)
    }
    
    // MARK: - WidgetInternalViewModelProtocol
    
    override func startContentSubscription() {
        super.startContentSubscription()
        updateSubscription()
    }
    
    override func stopContentSubscription() {
        super.stopContentSubscription()
        setsSubscriptionService.stopSubscription()
    }
    
    func screenData() -> EditorScreenData? {
        return .sets
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .sets
    }
    
    // MARK: - CommonWidgetInternalViewModel oveerides
    
    override func widgetInfoUpdated() {
        updateSubscription()
    }
    
    // MARK: - Private func
    
    private func updateSubscription() {
        guard let widgetInfo, contentIsAppear else { return }
        setsSubscriptionService.startSubscription(
            objectLimit: widgetInfo.fixedLimit,
            update: { [weak self] _, update in
                var details = self?.details ?? []
                details.applySubscriptionUpdate(update)
                self?.details = details
            }
        )
    }
}
