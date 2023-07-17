import Foundation
import Services
import Combine

final class ObjectWidgetInternalViewModel: CommonWidgetInternalViewModel, WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let subscriptionManager: TreeSubscriptionManagerProtocol
    
    // MARK: - State
    
    private var subscriptions = [AnyCancellable]()
    private var linkedObjectDetails: ObjectDetails?
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = ""
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    
    init(
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol,
        subscriptionManager: TreeSubscriptionManagerProtocol
    ) {
        self.subscriptionManager = subscriptionManager
        super.init(widgetBlockId: widgetBlockId, widgetObject: widgetObject)
    }
    
    override func startHeaderSubscription() {
        super.startHeaderSubscription()
        widgetObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId)
            .receiveOnMain()
            .sink { [weak self] details in
                self?.name = details.title
                self?.linkedObjectDetails = details
                self?.updateLinksSubscriptions()
            }
            .store(in: &subscriptions)
        
        subscriptionManager.handler = { [weak self] details in
            // Middlware don't sort objects by passed ids
            guard let links = self?.linkedObjectDetails?.links else { return }
            self?.details = details.sorted { a, b in
                return links.firstIndex(of: a.id) ?? 0 < links.firstIndex(of: b.id) ?? 0
            }
        }
    }
    
    override func stopHeaderSubscription() {
        super.stopHeaderSubscription()
        subscriptions.removeAll()
    }
    
    override func startContentSubscription() {
        super.startContentSubscription()
        updateLinksSubscriptions()
    }
    
    override func stopContentSubscription() {
        super.stopContentSubscription()
        subscriptionManager.stopAllSubscriptions()
    }
    
    func screenData() -> EditorScreenData? {
        guard let linkedObjectDetails else { return nil }
        return linkedObjectDetails.editorScreenData()
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .object(type: linkedObjectDetails?.analyticsType ?? .object(typeId: ""))
    }
    
    // MARK: - Private
    
    private func updateLinksSubscriptions() {
        guard let linkedObjectDetails, contentIsAppear else { return }
        
        _ = subscriptionManager.startOrUpdateSubscription(objectIds: linkedObjectDetails.links)
    }
}
