import Foundation
import BlocksModels
import Combine

@MainActor
final class ObjectTreeWidgetViewModel: ObservableObject {
    
    private enum Constants {
        static let maxExpandableLevel = 2
    }
    
    private struct ExpandedId {
        let rowId: String
        let objectId: String
    }
    
    // MARK: - DI
    // TODO: For debug. Make private
    let widgetBlockId: BlockId
    private let widgetObject: HomeWidgetsObjectProtocol
    private let objectDetailsStorage: ObjectDetailsStorage
    private let subscriptionManager: ObjectTreeSubscriptionManagerProtocol
    private let blockWidgetService: BlockWidgetServiceProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    private var subscriptions = [AnyCancellable]()
    private var linkedObjectDetails: ObjectDetails?
    private var subscriptionData: [ObjectDetails] = []
    private var expandedRowIds: [ExpandedId] = []
    
    @Published var name: String = ""
    @Published var isExpanded: Bool = true
    @Published var rows: [ObjectTreeWidgetRowViewModel] = []
    
    init(
        widgetBlockId: BlockId,
        widgetObject: HomeWidgetsObjectProtocol,
        objectDetailsStorage: ObjectDetailsStorage,
        subscriptionManager: ObjectTreeSubscriptionManagerProtocol,
        blockWidgetService: BlockWidgetServiceProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.objectDetailsStorage = objectDetailsStorage
        self.subscriptionManager = subscriptionManager
        self.blockWidgetService = blockWidgetService
        self.output = output
    }
    
    // MARK: - Public
    
    func onAppear() {
        setupAllSubscriptions()
    }
    
    func onAppearList() {
        updateLinksSubscriptionsAndTree()
    }
    
    func onDisappear() {
        subscriptions.removeAll()
        subscriptionManager.stopAllSubscriptions()
    }
    
    func onDisappearList() {
        subscriptionManager.stopAllSubscriptions()
    }
    
    func onDeleteWidgetTap() {
        Task {
            try? await blockWidgetService.removeWidgetBlock(
                contextId: widgetObject.objectId,
                widgetBlockId: widgetBlockId
            )
        }
    }
    
    // MARK: - Private
    
    private func onTapExpand(model: ObjectTreeWidgetRowViewModel) {
        expandedRowIds.append(ExpandedId(rowId: model.rowId, objectId: model.objectId))
        updateLinksSubscriptionsAndTree()
    }
    
    private func onTapCollapse(model: ObjectTreeWidgetRowViewModel) {
        expandedRowIds.removeAll { $0.rowId == model.rowId }
        updateLinksSubscriptionsAndTree()
    }
    
    private func setupAllSubscriptions() {
        
        guard let tagetObjectId = widgetObject.targetObjectIdByLinkFor(widgetBlockId: widgetBlockId)
            else { return }
        
        objectDetailsStorage.publisherFor(id: tagetObjectId)
            .compactMap { $0 }
            .receiveOnMain()
            .sink { [weak self] details in
                self?.linkedObjectDetails = details
                self?.name = details.title
                self?.updateLinksSubscriptionsAndTree()
            }
            .store(in: &subscriptions)
        
        widgetObject.infoContainer.publisherFor(id: widgetBlockId)
            .sink { [weak self] info in
                guard case let .widget(widget) = info?.content else { return }
                self?.isExpanded = widget.layout == .tree
            }
            .store(in: &subscriptions)
        
        subscriptionManager.handler = { [weak self] details in
            self?.subscriptionData = details
            self?.updateLinksSubscriptionsAndTree()
        }
    }
    
    private func updateLinksSubscriptionsAndTree() {
        updateSubscriptions()
        updateTree()
    }
    
    private func updateSubscriptions() {
        guard let linkedObjectDetails else { return }
        
        let expandedObjectIds = expandedRowIds.map { $0.objectId }
        
        let childLinks = subscriptionData
            .filter { expandedObjectIds.contains($0.id) }
            .flatMap { $0.links }
        
        let objectIds = linkedObjectDetails.links + childLinks
        subscriptionManager.startOrUpdateSubscription(objectIds: objectIds)
    }
    
    private func updateTree() {
        guard let linkedObjectDetails else { return }
        rows = buildRows(links: linkedObjectDetails.links, idPrefix: linkedObjectDetails.id, level: 0)
    }
    
    private func buildRows(links: [String], idPrefix: String, level: Int) -> [ObjectTreeWidgetRowViewModel] {
        
        let rowsDetails = subscriptionData
            .filter { links.contains($0.id) }
            .reordered(by: links, transform: { $0.id })

        return rowsDetails.flatMap { details in
            // One object can be linked in different parent objects or can be linked to self.
            // We should create unique identity for correct save expanded state.
            // Id contains all parent id. It's like path.
            let rowId = "\(idPrefix)-\(details.id)"
            let isExpanded = expandedRowIds.contains { $0.rowId == rowId }
            
            let row = ObjectTreeWidgetRowViewModel(
                rowId: rowId,
                objectId: details.id,
                title: details.title,
                icon: details.objectIconImage,
                expandedType: details.expandedType(
                    isExpanded: isExpanded,
                    canBeExpanded: level < Constants.maxExpandableLevel
                ),
                level: level,
                tapExpand: { [weak self] model in
                    self?.onTapExpand(model: model)
                },
                tapCollapse: { [weak self] model in
                    self?.onTapCollapse(model: model)
                },
                tapObject: { [weak self] _ in
                    let data = EditorScreenData(pageId: details.id, type: details.editorViewType)
                    self?.output?.onObjectSelected(screenData: data)
                }
            )
            
            if isExpanded {
                let child = buildRows(links: details.links, idPrefix: row.rowId, level: level + 1)
                return [row] + child
            }
            
            return [row]
        }
    }
}

private extension ObjectDetails {
    func expandedType(isExpanded: Bool, canBeExpanded: Bool) -> ObjectTreeWidgetRowViewModel.ExpandedType {
        switch editorViewType {
        case .page:
            return links.isEmpty || !canBeExpanded ? .dot : .arrow(expanded: isExpanded)
        case .set:
            return .set
        }
    }
}
