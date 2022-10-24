import BlocksModels
import Combine
import OrderedCollections
import Foundation

final class SetKanbanViewModel: ObservableObject {
    @Published var configurationsDict: OrderedDictionary<SubscriptionId, [SetContentViewItemConfiguration]> = [:]
    var recordsDict: OrderedDictionary<SubscriptionId, [ObjectDetails]> = [:]
    
    private var dataView = BlockDataview.empty
    var activeView: DataviewView {
        dataView.views.first { $0.id == dataView.activeViewId } ?? .empty
    }
    
    private let document: BaseDocument
    private var cancellable: Cancellable?
    
    private let onIconTap: (ObjectDetails) -> Void
    private let onItemTap: (ObjectDetails) -> Void
    
    private let relationSearchDistinctService = RelationSearchDistinctService()
    private let subscriptionService = ServiceLocator.shared.subscriptionService()
    private let setSubscriptionDataBuilder = SetSubscriptionDataBuilder()
    private let dataBuilder = SetContentViewDataBuilder()
    
    init(
        document: BaseDocument,
        onIconTap: @escaping (ObjectDetails) -> Void,
        onItemTap: @escaping (ObjectDetails) -> Void
    ) {
        self.document = document
        self.onIconTap = onIconTap
        self.onItemTap = onItemTap
        self.setupSubscription()
    }
    
    func onAppear() {
        updateGroups()
    }
    
    func onDisappear() {
        subscriptionService.stopAllSubscriptions()
    }
    
    private func setupSubscription() {
        cancellable = document.updatePublisher.sink { [weak self] update in
            self?.onUpdate(update)
        }
    }
    
    private func onUpdate(_ update: DocumentUpdate) {
        switch update {
        case .details, .general, .blocks, .dataSourceUpdate:
            dataView = document.dataviews.first ?? .empty
            updateGroups()
        case .header, .syncStatus:
            break
        }
    }
    
    private func updateGroups() {
        guard activeView.groupRelationKey.isNotEmpty else { return }
        recordsDict = [:]
        
        Task { @MainActor in
            let groups = try await relationSearchDistinctService.searchDistinct(
                relationKey: activeView.groupRelationKey,
                filters: activeView.filters
            )
            groups.forEach { [weak self] group in
                self?.updateSubscription(with: group)
            }
        }
    }
    
    private func updateSubscription(with group: DataviewGroup) {
        let groupFilter = group.filter(with: activeView.groupRelationKey)
        let subscriptionId = SubscriptionId(value: "\(document.objectId)-dataview:\(group.id)")
        startSubscriptionIfNeeded(with: subscriptionId, groupFilter: groupFilter)
    }
    
    private func startSubscriptionIfNeeded(with subscriptionId: SubscriptionId, groupFilter: DataviewFilter? = nil) {
        let data = setSubscriptionDataBuilder.set(
            .init(
                identifier: subscriptionId,
                dataView: dataView,
                view: activeView,
                groupFilter: groupFilter,
                currentPage: 1
            )
        )
        // thinking about it
//        if subscriptionService.hasSubscriptionDataDiff(with: data) {
            restartSubscription(with: data)
//        }
    }
    
    private func restartSubscription(with data: SubscriptionData) {
        subscriptionService.stopSubscription(id: data.identifier)
        subscriptionService.startSubscription(data: data) { [weak self] subId, update in
            self?.updateData(with: subId, update: update)
        }
    }
    
    private func updateData(with subscriptionId: SubscriptionId, update: SubscriptionUpdate) {
        if case .pageCount = update {
            return
        }
        
        updateRecords(for: subscriptionId, update: update)
        updateConfigurations(for: subscriptionId)
    }
    
    private func updateRecords(for subscriptionId: SubscriptionId, update: SubscriptionUpdate) {
        var records = recordsDict[subscriptionId, default: []]
        records.applySubscriptionUpdate(update)
        recordsDict[subscriptionId] = records
    }
    
    private func updateConfigurations(for subscriptionId: SubscriptionId) {
        let records = recordsDict[subscriptionId, default: []]
        let configurations = dataBuilder.itemData(
            records,
            dataView: dataView,
            activeView: activeView,
            isObjectLocked: true,
            onIconTap: onIconTap,
            onItemTap: onItemTap
        )
        configurationsDict[subscriptionId] = configurations
    }
}
