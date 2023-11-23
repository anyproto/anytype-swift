import Foundation
import Services
import Combine

@MainActor
final class ObjectWidgetInternalViewModel: CommonWidgetInternalViewModel, WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let subscriptionManager: TreeSubscriptionManagerProtocol
    private let pageRepository: PageRepositoryProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    
    private var subscriptions = [AnyCancellable]()
    private var linkedObjectDetails: ObjectDetails?
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = ""
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    var allowCreateObject = true
    
    init(
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol,
        subscriptionManager: TreeSubscriptionManagerProtocol,
        pageRepository: PageRepositoryProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.subscriptionManager = subscriptionManager
        self.pageRepository = pageRepository
        self.output = output
        super.init(widgetBlockId: widgetBlockId, widgetObject: widgetObject)
    }
    
    override func startHeaderSubscription() {
        super.startHeaderSubscription()
        widgetObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId)
            .receiveOnMain()
            .sink { [weak self] details in
                self?.name = details.title
                self?.linkedObjectDetails = details
                Task { await self?.updateLinksSubscriptions() }
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
    
    override func startContentSubscription() async {
        await super.startContentSubscription()
        await updateLinksSubscriptions()
    }
    
    override func stopContentSubscription() async {
        await super.stopContentSubscription()
        await subscriptionManager.stopAllSubscriptions()
    }
    
    func screenData() -> EditorScreenData? {
        guard let linkedObjectDetails else { return nil }
        return linkedObjectDetails.editorScreenData()
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .object(type: linkedObjectDetails?.analyticsType ?? .object(typeId: ""))
    }
    
    func onCreateObjectTap() {
        Task {
            let details = try await pageRepository.createDefaultPage(name: "", shouldDeleteEmptyObject: true, spaceId: widgetObject.spaceId)
            output?.onObjectSelected(screenData: details.editorScreenData())
        }
    }
    
    // MARK: - Private
    
    private func updateLinksSubscriptions() async {
        guard let linkedObjectDetails, contentIsAppear else { return }
        
        await _ = subscriptionManager.startOrUpdateSubscription(objectIds: linkedObjectDetails.links)
    }
}
