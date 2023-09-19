import Foundation
import Services
import Combine
import SwiftUI
import AnytypeCore

@MainActor
final class TreeWidgetViewModel: ObservableObject, WidgetContainerContentViewModelProtocol {
    
    private enum Constants {
        static let maxExpandableLevel = 3
    }
    
    private struct ExpandedId {
        let rowId: String
        let objectId: String
    }
    
    // MARK: - DI

    private let internalModel: any WidgetInternalViewModelProtocol
    private let subscriptionManager: TreeSubscriptionManagerProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State

    private var subscriptions = [AnyCancellable]()
    private var childSubscriptionData: [ObjectDetails]?
    private var firstLevelSubscriptionData: [ObjectDetails]?
    private var expandedRowIds: [ExpandedId] = []
    @Published var rows: [TreeWidgetRowViewModel]?
    
    // MARK: - WidgetContainerContentViewModelProtocol
    
    @Published private(set) var name: String = ""
    let dragId: String?
    
    init(
        widgetBlockId: BlockId,
        internalModel: any WidgetInternalViewModelProtocol,
        subscriptionManager: TreeSubscriptionManagerProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.dragId = widgetBlockId
        self.internalModel = internalModel
        self.subscriptionManager = subscriptionManager
        self.objectActionsService = objectActionsService
        self.output = output
    }
    
    // MARK: - WidgetContainerContentViewModelProtocol
    
    func startHeaderSubscription() {
        internalModel.startHeaderSubscription()
        setupAllSubscriptions()
    }
    
    func startContentSubscription() {
        internalModel.startContentSubscription()
        updateLinksSubscriptionsAndTree()
    }
    
    func stopHeaderSubscription() {
        internalModel.stopHeaderSubscription()
        subscriptions.removeAll()
        subscriptionManager.handler = nil
    }
    
    func stopContentSubscription() {
        internalModel.stopContentSubscription()
        subscriptionManager.stopAllSubscriptions()
    }
    
    func onHeaderTap() {
        guard let screenData = internalModel.screenData() else { return }
        AnytypeAnalytics.instance().logSelectHomeTab(source: internalModel.analyticsSource())
        output?.onObjectSelected(screenData: screenData)
    }
    
    // MARK: - Private
    
    private func onTapExpand(model: TreeWidgetRowViewModel) {
        expandedRowIds.append(ExpandedId(rowId: model.rowId, objectId: model.objectId))
        UISelectionFeedbackGenerator().selectionChanged()
        updateLinksSubscriptionsAndTree()
    }
    
    private func onTapCollapse(model: TreeWidgetRowViewModel) {
        expandedRowIds.removeAll { $0.rowId == model.rowId }
        UISelectionFeedbackGenerator().selectionChanged()
        updateLinksSubscriptionsAndTree()
    }
    
    private func setupAllSubscriptions() {
        
        internalModel.namePublisher
            .receiveOnMain()
            .assign(to: &$name)
        
        subscriptionManager.handler = { [weak self] details in
            self?.childSubscriptionData = details
            self?.updateLinksSubscriptionsAndTree()
        }
        
        internalModel.detailsPublisher
            .receiveOnMain()
            .sink { [weak self] details in
                self?.firstLevelSubscriptionData = details
                self?.updateLinksSubscriptionsAndTree()
            }
            .store(in: &subscriptions)
    }
    
    private func updateLinksSubscriptionsAndTree() {
        let expandedObjectIds = expandedRowIds.map(\.objectId)
        let firstLevelIds = firstLevelSubscriptionData?.map(\.id) ?? []
        
        let childLinks = subscriptionData
            .filter { expandedObjectIds.contains($0.id) }
            .flatMap(\.links)
            .filter { !firstLevelIds.contains($0) }
        
        if !subscriptionManager.startOrUpdateSubscription(objectIds: childLinks) {
            updateTree()
        }
    }
    
    private func updateTree() {
        guard let firstLevelSubscriptionData else { return }
        let links = firstLevelSubscriptionData.map { $0.id }
        withAnimation {
            rows = buildRows(links: links, idPrefix: "", level: 0)
        }
    }
    
    private func buildRows(links: [String], idPrefix: String, level: Int) -> [TreeWidgetRowViewModel] {
        
        let rowsDetails = subscriptionData
            .filter { links.contains($0.id) }
            .reordered(by: links, transform: { $0.id })

        return rowsDetails.flatMap { details in
            // One object can be linked in different parent objects or can be linked to self.
            // We should create unique identity for correct save expanded state.
            // Id contains all parent id. It's like path.
            let rowId = "\(idPrefix)-\(details.id)"
            let isExpanded = expandedRowIds.contains { $0.rowId == rowId }
            
            let row = TreeWidgetRowViewModel(
                rowId: rowId,
                objectId: details.id,
                title: details.title,
                icon: details.objectIconImage,
                expandedType: details.expandedType(
                    isExpanded: isExpanded,
                    canBeExpanded: level < Constants.maxExpandableLevel
                ),
                level: level,
                onIconTap: { [weak self] in
                    self?.updateDone(details: details)
                },
                tapExpand: { [weak self] model in
                    self?.onTapExpand(model: model)
                },
                tapCollapse: { [weak self] model in
                    self?.onTapCollapse(model: model)
                },
                tapObject: { [weak self] _ in
                    self?.output?.onObjectSelected(screenData: details.editorScreenData())
                }
            )
            
            if isExpanded {
                let child = buildRows(links: details.links, idPrefix: row.rowId, level: level + 1)
                return [row] + child
            }
            
            return [row]
        }
    }
    
    private var subscriptionData: [ObjectDetails] {
        return (firstLevelSubscriptionData ?? []) + (childSubscriptionData ?? [])
    }
    
    private func updateDone(details: ObjectDetails) {
        guard details.layoutValue == .todo else { return }
        
        Task {
            try await objectActionsService.updateBundledDetails(contextID: details.id, details: [.done(!details.done)])
        }
    }
}

private extension ObjectDetails {
    func expandedType(isExpanded: Bool, canBeExpanded: Bool) -> TreeWidgetRowViewModel.ExpandedType {
        switch editorViewType {
        case .page:
            return links.isEmpty || !canBeExpanded ? .icon(asset: .Widget.dot) : .arrow(expanded: isExpanded)
        case .set:
            return isCollection ? .icon(asset: .Widget.collection) : .icon(asset: .Widget.set)
        }
    }
}
