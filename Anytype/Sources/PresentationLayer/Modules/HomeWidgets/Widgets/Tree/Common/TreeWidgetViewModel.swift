import Foundation
import Services
import Combine
import SwiftUI
import AnytypeCore

@MainActor
final class TreeWidgetViewModel: ObservableObject {
    
    private enum Constants {
        static let maxExpandableLevel = 3
    }
    
    private struct ExpandedId {
        let rowId: String
        let objectId: String
    }
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let widgetObject: any BaseDocumentProtocol
    private let internalModel: any WidgetInternalViewModelProtocol
    private weak var output: (any CommonWidgetModuleOutput)?
    
    @Injected(\.treeSubscriptionManager)
    private var subscriptionManager: any TreeSubscriptionManagerProtocol
    
    // MARK: - State

    private var subscriptions = [AnyCancellable]()
    private var childSubscriptionData: [ObjectDetails]?
    private var firstLevelSubscriptionData: [ObjectDetails]?
    private var expandedRowIds: [ExpandedId] = []
    @Published var rows: [TreeWidgetRowViewModel]?
    
    // MARK: - WidgetContainerContentViewModelProtocol
    
    @Published private(set) var name: String = ""
    var dragId: String? { widgetBlockId }
    var allowCreateObject: Bool { internalModel.allowCreateObject }
    
    init(
        widgetBlockId: String,
        widgetObject: any BaseDocumentProtocol,
        internalModel: any WidgetInternalViewModelProtocol,
        output: (any CommonWidgetModuleOutput)?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.internalModel = internalModel
        self.output = output
        startHeaderSubscription()
        startContentSubscription()
    }
    
    func onHeaderTap() {
        guard let screenData = internalModel.screenData() else { return }
        guard let info = widgetObject.widgetInfo(blockId: widgetBlockId) else { return }
        AnytypeAnalytics.instance().logClickWidgetTitle(source: internalModel.analyticsSource(), createType: info.widgetCreateType)
        output?.onObjectSelected(screenData: screenData)
    }
    
    func onCreateObjectTap() {
        internalModel.onCreateObjectTap()
    }
    
    func startTreeSubscription() async {
        for await details in subscriptionManager.detailsPublisher.values {
            childSubscriptionData = details
            await updateLinksSubscriptionsAndTree()
        }
    }
    
    // MARK: - Private
    
    private func startHeaderSubscription() {
        internalModel.startHeaderSubscription()
        setupAllSubscriptions()
    }
    
    private func startContentSubscription() {
        Task {
            await internalModel.startContentSubscription()
            await updateLinksSubscriptionsAndTree()
        }
    }
    
    private func onTapExpand(model: TreeWidgetRowViewModel) {
        expandedRowIds.append(ExpandedId(rowId: model.rowId, objectId: model.objectId))
        UISelectionFeedbackGenerator().selectionChanged()
        Task { await updateLinksSubscriptionsAndTree() }
    }
    
    private func onTapCollapse(model: TreeWidgetRowViewModel) {
        expandedRowIds.removeAll { $0.rowId == model.rowId }
        UISelectionFeedbackGenerator().selectionChanged()
        Task { await updateLinksSubscriptionsAndTree() }
    }
    
    private func setupAllSubscriptions() {
        
        internalModel.namePublisher
            .receiveOnMain()
            .assign(to: &$name)
        
        internalModel.detailsPublisher
            .receiveOnMain()
            .sink { [weak self] details in
                self?.firstLevelSubscriptionData = details
                Task { await self?.updateLinksSubscriptionsAndTree() }
            }
            .store(in: &subscriptions)
    }
    
    private func updateLinksSubscriptionsAndTree() async {
        let expandedObjectIds = expandedRowIds.map(\.objectId)
        let firstLevelIds = firstLevelSubscriptionData?.map(\.id) ?? []
        
        let childLinks = subscriptionData
            .filter { expandedObjectIds.contains($0.id) }
            .flatMap(\.links)
            .filter { !firstLevelIds.contains($0) }
        
        let updated = await subscriptionManager.startOrUpdateSubscription(spaceId: widgetObject.spaceId, objectIds: childLinks)
        if !updated {
            updateTree()
        }
    }
    
    private func updateTree() {
        guard let firstLevelSubscriptionData else { return }
        let links = firstLevelSubscriptionData.map { $0.id }
        withAnimation(rows.isNil ? nil : .default) {
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
                title: details.pluralTitle,
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
                    self?.handleTapOnObject(details: details)
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
    
    private func handleTapOnObject(details: ObjectDetails) {
        guard let info = widgetObject.widgetInfo(blockId: widgetBlockId) else { return }
        AnytypeAnalytics.instance().logOpenSidebarObject(createType: info.widgetCreateType)
        output?.onObjectSelected(screenData: details.screenData())
    }
}

private extension ObjectDetails {
    func expandedType(isExpanded: Bool, canBeExpanded: Bool) -> TreeWidgetRowViewModel.ExpandedType {
        switch editorViewType {
        case .page, .bookmark:
            return links.isEmpty || !canBeExpanded ? .icon(asset: .X18.objectWithoutIcon) : .arrow(expanded: isExpanded)
        case .list:
            return .icon(asset: .X18.list)
        case .date, .type, .participant, .mediaFile, .chat:
            return .icon(asset: .X18.objectWithoutIcon)
        }
    }
}
