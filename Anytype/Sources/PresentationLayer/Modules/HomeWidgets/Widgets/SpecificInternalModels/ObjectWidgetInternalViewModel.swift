import Foundation
import Services
import Combine
import UIKit

@MainActor
final class ObjectWidgetInternalViewModel: ObservableObject, WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let widgetObject: any BaseDocumentProtocol
    private weak var output: (any CommonWidgetModuleOutput)?
    
    @Injected(\.treeSubscriptionManager)
    private var subscriptionManager: any TreeSubscriptionManagerProtocol
    @Injected(\.defaultObjectCreationService)
    private var defaultObjectService: any DefaultObjectCreationServiceProtocol
    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol
    @Injected(\.blockService)
    private var blockService: any BlockServiceProtocol
    
    // MARK: - State
    
    private var linkedObjectDetails: ObjectDetails?
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = ""
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    @Published var allowCreateObject = true
    
    init(data: WidgetSubmoduleData) {
        self.widgetBlockId = data.widgetBlockId
        self.widgetObject = data.widgetObject
        self.output = data.output
    }
    
    func startHeaderSubscription() {}
    
    func startBlockSubscription() async {
        for await details in widgetObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId).values {
            name = details.title
            allowCreateObject = details.permissions(participantCanEdit: true).canEditBlocks
            
            linkedObjectDetails = details
            await updateLinksSubscriptions()
        }
    }
    
    func startTreeSubscription() async {
        for await details in subscriptionManager.detailsPublisher.values {
            guard let links = linkedObjectDetails?.links else { continue }
            self.details = details.sorted { a, b in
                return links.firstIndex(of: a.id) ?? 0 < links.firstIndex(of: b.id) ?? 0
            }
        }
    }
    
    func startContentSubscription() async {
        await updateLinksSubscriptions()
    }
    
    func screenData() -> ScreenData? {
        guard let linkedObjectDetails else { return nil }
        return linkedObjectDetails.screenData()
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .object(type: linkedObjectDetails?.analyticsType ?? .object(typeId: ""))
    }
    
    func onCreateObjectTap() {
        guard let linkedObjectDetails else { return }
        Task {
            let document = documentsProvider.document(objectId: linkedObjectDetails.id, spaceId: linkedObjectDetails.spaceId, mode: .preview)
            try await document.open()
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
            output?.onObjectSelected(screenData: details.screenData())
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    // MARK: - Private
    
    private func updateLinksSubscriptions() async {
        guard let linkedObjectDetails else { return }
        await _ = subscriptionManager.startOrUpdateSubscription(spaceId: widgetObject.spaceId, objectIds: linkedObjectDetails.links)
    }
}
