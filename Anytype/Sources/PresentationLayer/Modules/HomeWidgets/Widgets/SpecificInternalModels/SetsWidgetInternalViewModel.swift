import Foundation
import Services
import Combine

@MainActor
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
    
    override func startContentSubscription() async {
        await super.startContentSubscription()
        await updateSubscription()
    }
    
    override func stopContentSubscription() async {
        await super.stopContentSubscription()
        await setsSubscriptionService.stopSubscription()
    }
    
    func screenData() -> EditorScreenData? {
        return .sets
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .sets
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
        await setsSubscriptionService.startSubscription(
            objectLimit: widgetInfo.fixedLimit,
            update: { [weak self] details in
                self?.details = details
            }
        )
    }
}
