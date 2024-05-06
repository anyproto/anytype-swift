import Foundation
import Services
import Combine
import UIKit

@MainActor
final class ObjectWidgetInternalViewModel: WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let widgetObject: BaseDocumentProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    @Injected(\.treeSubscriptionManager)
    private var subscriptionManager: TreeSubscriptionManagerProtocol
    @Injected(\.defaultObjectCreationService)
    private var defaultObjectService: DefaultObjectCreationServiceProtocol
    @Injected(\.documentsProvider)
    private var documentsProvider: DocumentsProviderProtocol
    @Injected(\.blockService)
    private var blockService: BlockServiceProtocol
    
    // MARK: - State
    
    private var subscriptions = [AnyCancellable]()
    private var linkedObjectDetails: ObjectDetails?
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = ""
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    @Published var allowCreateObject = true
    
    init(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.output = output
    }
    
    func startHeaderSubscription() {
        widgetObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId)
            .receiveOnMain()
            .sink { [weak self] details in
                self?.name = details.title
                self?.allowCreateObject = details.permissions(participantCanEdit: true).canEditBlocks
                
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
    
    func startContentSubscription() async {
        await updateLinksSubscriptions()
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
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: .widget)
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
        guard let linkedObjectDetails else { return }
        await _ = subscriptionManager.startOrUpdateSubscription(objectIds: linkedObjectDetails.links)
    }
}
