import Foundation
import SwiftUI
import Services
import Combine

@MainActor
@Observable
final class SetSortsListViewModel {
    var rows: [SetSortRowConfiguration] = []

    @ObservationIgnored
    private let setDocument: any SetDocumentProtocol
    @ObservationIgnored
    private let viewId: String
    @ObservationIgnored
    private var cancellable: (any Cancellable)?

    @ObservationIgnored
    @Injected(\.dataviewService)
    private var dataviewService: any DataviewServiceProtocol

    @ObservationIgnored
    private var deletingSortIds = Set<String>()
    @ObservationIgnored
    private weak var output: (any SetSortsListCoordinatorOutput)?
    
    init(
        setDocument: some SetDocumentProtocol,
        viewId: String,
        output: (any SetSortsListCoordinatorOutput)?
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
        self.output = output
        self.setup()
    }
}

extension SetSortsListViewModel {
    
    // MARK: - Routing
    
    func addButtonTapped() {
        let excludeRelations: [PropertyDetails] = setDocument.sorts(for: viewId).map { $0.relationDetails }
        let relationsDetails = setDocument.viewRelations(viewId: viewId, excludeRelations: excludeRelations)
        output?.onAddButtonTap(relationDetails: relationsDetails, completion: { [weak self] relationDetails in
            self?.addNewSort(with: relationDetails)
        })
    }
    
    func rowTapped(_ id: String, index: Int) {
        guard let setSort = setDocument.sorts(for: viewId)[safe: index], setSort.id == id  else {
            return
        }
        output?.onSetSortTap(setSort, completion: { [weak self] setSort, type in
            self?.updateSorts(with: setSort, type: type)
        })
    }
    
    // MARK: - Actions
    
    func delete(_ indexSet: IndexSet) {
        let sorts = setDocument.sorts(for: viewId)

        for deleteIndex in indexSet {
            guard deleteIndex < sorts.count else { continue }
            deletingSortIds.insert(sorts[deleteIndex].sort.id)
        }
        rows.remove(atOffsets: indexSet)

        for deleteIndex in indexSet {
            guard deleteIndex < sorts.count else { continue }
            let sort = sorts[deleteIndex]
            Task { [weak self] in
                guard let self else { return }
                defer { deletingSortIds.remove(sort.sort.id) }
                try await dataviewService.removeSorts(
                    objectId: setDocument.objectId,
                    blockId: setDocument.blockId,
                    ids: [sort.sort.id],
                    viewId: viewId
                )
                AnytypeAnalytics.instance().logSortRemove(objectType: setDocument.analyticsType)
            }
        }
    }
    
    func move(from: IndexSet, to: Int) {
        Task { [weak self] in
            guard let self else { return }
            var sorts = setDocument.sorts(for: viewId)
            sorts.move(fromOffsets: from, toOffset: to)
            let sortIds = sorts.map { $0.sort.id }
            try await dataviewService.sortSorts(
                objectId: setDocument.objectId,
                blockId: setDocument.blockId,
                ids: sortIds,
                viewId: viewId
            )
            AnytypeAnalytics.instance().logRepositionSort(objectType: setDocument.analyticsType)
        }
    }
    
    func addNewSort(with relation: PropertyDetails) {
        let newSort = DataviewSort(
            relationKey: relation.key,
            type: .asc
        )
        Task { [weak self] in
            guard let self else { return }
            try await dataviewService.addSort(
                objectId: setDocument.objectId,
                blockId: setDocument.blockId,
                sort: newSort, 
                viewId: viewId
            )
            AnytypeAnalytics.instance().logAddSort(objectType: setDocument.analyticsType)
        }
    }
    
    private func setup() {
        cancellable = setDocument.syncPublisher.receiveOnMain().sink { [weak self] in
            guard let self else { return }
            let sorts = setDocument.sorts(for: viewId)
            updateRows(with: sorts)
        }
    }
    
    private func updateRows(with sorts: [SetSort]) {
        let activeSorts = sorts.filter { !deletingSortIds.contains($0.sort.id) }
        rows = activeSorts.enumerated().map { index, sort in
            SetSortRowConfiguration(
                id: "\(sort.relationDetails.id)_\(index)",
                title: sort.relationDetails.name,
                subtitle: sort.typeTitle() ?? "",
                iconAsset: sort.relationDetails.format.iconAsset,
                onTap: { [weak self] in
                    self?.rowTapped(sort.relationDetails.id, index: index)
                }
            )
        }
    }
    
    private func updateSorts(with setSort: SetSort, type: String) {
        Task { [weak self] in
            guard let self else { return }
            try await dataviewService.replaceSort(
                objectId: setDocument.objectId,
                blockId: setDocument.blockId,
                id: setSort.sort.id,
                sort: setSort.sort,
                viewId: viewId
            )
            AnytypeAnalytics.instance().logChangeSortValue(
                type: type,
                objectType: setDocument.analyticsType
            )
        }
    }
}
