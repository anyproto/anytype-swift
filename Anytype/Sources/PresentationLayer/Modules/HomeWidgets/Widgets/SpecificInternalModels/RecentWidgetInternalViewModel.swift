import Foundation
import Services
import Combine

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
    
    override func startContentSubscription() {
        super.startContentSubscription()
        updateSubscription()
    }
    
    override func stopContentSubscription() {
        super.stopContentSubscription()
        recentSubscriptionService.stopSubscription()
    }
    
    func screenData() -> EditorScreenData? {
        return type.editorScreenData
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return type.analyticsSource
    }
    
    // MARK: - CommonWidgetInternalViewModel oveerides
    
    override func widgetInfoUpdated() {
        updateSubscription()
    }
    
    // MARK: - Private func
    
    private func updateSubscription() {
        guard let widgetInfo, contentIsAppear else { return }
        recentSubscriptionService.startSubscription(
            type: type,
            objectLimit: widgetInfo.fixedLimit,
            update: { [weak self] _, update in
                var details = self?.details ?? []
                details.applySubscriptionUpdate(update)
                self?.details = details
            }
        )
    }
}
