import Foundation
import Services
import Combine

final class ObjectWidgetInternalViewModel: WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let widgetBlockId: BlockId
    private let widgetObject: BaseDocumentProtocol
    private let subscriptionManager: TreeSubscriptionManagerProtocol
    
    // MARK: - State
    
    private var contentIsAppear = false
    private var subscriptions = [AnyCancellable]()
    private var linkedObjectDetails: ObjectDetails?
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = Loc.favorites
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    
    init(
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol,
        subscriptionManager: TreeSubscriptionManagerProtocol
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.subscriptionManager = subscriptionManager
    }
    
    func startHeaderSubscription() {
        guard let tagetObjectId = widgetObject.targetObjectIdByLinkFor(widgetBlockId: widgetBlockId)
            else { return }
        
        widgetObject.detailsStorage.publisherFor(id: tagetObjectId)
            .compactMap { $0 }
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
    
    func stopHeaderSubscription() {
        subscriptions.removeAll()
    }
    
    func startContentSubscription() {
        contentIsAppear = true
        updateLinksSubscriptions()
    }
    
    func stopContentSubscription() {
        contentIsAppear = false
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
