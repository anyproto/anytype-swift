import Foundation
import Services
import Combine
import UIKit

@MainActor
final class ObjectWidgetInternalViewModel: CommonWidgetInternalViewModel, WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let subscriptionManager: TreeSubscriptionManagerProtocol
    private let defaultObjectService: DefaultObjectCreationServiceProtocol
    private let documentsProvider: DocumentsProviderProtocol
    private let blockService: BlockServiceProtocol
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
        defaultObjectService: DefaultObjectCreationServiceProtocol,
        documentsProvider: DocumentsProviderProtocol,
        blockService: BlockServiceProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.subscriptionManager = subscriptionManager
        self.defaultObjectService = defaultObjectService
        self.documentsProvider = documentsProvider
        self.blockService = blockService
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
        guard let linkedObjectDetails else { return }
        Task {
            let document = documentsProvider.document(objectId: linkedObjectDetails.id, forPreview: true)
            try await document.openForPreview()
            guard let lastBlockId = document.children.last?.id else { return }
                  
            let details = try await defaultObjectService.createDefaultObject(name: "", shouldDeleteEmptyObject: true, spaceId: widgetObject.spaceId)
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, route: .widget)
            let info = BlockInformation.emptyLink(targetId: details.id)
            let _ = try await self.blockService.add(
                contextId: linkedObjectDetails.id,
                targetId: lastBlockId,
                info: info,
                position: .bottom
            )
            output?.onObjectSelected(screenData: details.editorScreenData())
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    // MARK: - Private
    
    private func updateLinksSubscriptions() async {
        guard let linkedObjectDetails, contentIsAppear else { return }
        await _ = subscriptionManager.startOrUpdateSubscription(objectIds: linkedObjectDetails.links)
    }
}
