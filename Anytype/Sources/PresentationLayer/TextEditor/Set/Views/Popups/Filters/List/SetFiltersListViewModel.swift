import Foundation
import SwiftUI
import Services
import FloatingPanel
import Combine

struct SetFiltersListModuleData {
    let setDocument: any SetDocumentProtocol
    let viewId: String
}

@MainActor
final class SetFiltersListViewModel: ObservableObject {
    @Published var rows: [SetFilterRowConfiguration] = []
    
    private let setDocument: any SetDocumentProtocol
    private let viewId: String
    private var cancellable: (any Cancellable)?
    
    @Injected(\.dataviewService)
    private var dataviewService: any DataviewServiceProtocol
    
    private let relationFilterBuilder = PropertyFilterBuilder()
    private let subscriptionDetailsStorage: ObjectDetailsStorage
    
    private weak var output: (any SetFiltersListCoordinatorOutput)?
    
    init(
        data: SetFiltersListModuleData,
        output: (any SetFiltersListCoordinatorOutput)?,
        subscriptionDetailsStorage: ObjectDetailsStorage)
    {
        self.setDocument = data.setDocument
        self.viewId = data.viewId
        self.output = output
        self.subscriptionDetailsStorage = subscriptionDetailsStorage
        self.setup()
    }
    
}

extension SetFiltersListViewModel {
    
    // MARK: - Actions
    
    func addButtonTapped() {
        let relationsDetails = setDocument.viewRelations(viewId: viewId, excludeRelations: [])
        output?.onAddButtonTap(relationDetails: relationsDetails) { [weak self] relationDetails in
            guard let filter = self?.makeSetFilter(with: relationDetails) else {
                return
            }
            self?.showFilterSearch(with: filter)
        }
    }
    
    func delete(_ indexSet: IndexSet) {
        indexSet.forEach { [weak self] deleteIndex in
            guard let self else { return }
            let filters = setDocument.filters(for: viewId)
            guard deleteIndex < filters.count else { return }
            let filter = filters[deleteIndex]
            Task { [weak self] in
                guard let self else { return }
                try await dataviewService.removeFilters(
                    objectId: setDocument.objectId,
                    blockId: setDocument.blockId,
                    ids: [filter.filter.id],
                    viewId: viewId
                )
                AnytypeAnalytics.instance().logFilterRemove(objectType: setDocument.analyticsType)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func setup() {
        cancellable = setDocument.syncPublisher.receiveOnMain().sink { [weak self] in
            guard let self else { return }
            let filters = setDocument.filters(for: viewId)
            updateRows(with: filters)
        }
    }
    
    private func updateRows(with filters: [SetFilter]) {
        rows = filters.enumerated().map { index, filter in
            SetFilterRowConfiguration(
                id: "\(filter.relationDetails.id)_\(index)",
                title: filter.relationDetails.name,
                subtitle: filter.conditionString,
                iconAsset: filter.relationDetails.format.iconAsset,
                type: type(for: filter),
                hasValues: filter.filter.condition.hasValues,
                onTap: { [weak self] in
                    self?.rowTapped(filter.relationDetails.id, index: index)
                }
            )
        }
    }
    
    private func rowTapped(_ id: String, index: Int) {
        guard let filter = setDocument.filters(for: viewId)[safe: index], filter.id == id  else {
            return
        }
        showFilterSearch(with: filter)
    }
    
    private func makeSetFilter(with relationDetails: RelationDetails) -> SetFilter? {
        guard let filteredDetails = setDocument.viewRelations(viewId: viewId, excludeRelations: []).first(where: { $0.id == relationDetails.id }) else {
            return nil
        }
        return SetFilter(
            relationDetails: filteredDetails,
            filter: DataviewFilter(
                relationKey: filteredDetails.key,
                condition: SetFilter.defaultCondition(for: filteredDetails),
                value: [String]().protobufValue
            )
        )
    }
    
    private func type(for filter: SetFilter) -> SetFilterRowType {
        switch filter.relationDetails.format {
        case .date:
            return .date(
                relationFilterBuilder.dateString(
                    for: filter.filter
                )
            )
        default:
            return .relation(
                relationFilterBuilder.relation(
                    detailsStorage: subscriptionDetailsStorage,
                    relationDetails: filter.relationDetails,
                    filter: filter.filter
                )
            )
        }
    }
    
    // MARK: - Routing
    
    func showFilterSearch(with filter: SetFilter) {
        output?.onFilterTap(filter: filter) { [weak self] updatedFilter in
            guard let self else { return }
            Task { [weak self] in
                guard let self else { return }
                if filter.filter.id.isNotEmpty {
                    try await dataviewService.replaceFilter(
                        objectId: setDocument.objectId,
                        blockId: setDocument.blockId,
                        id: filter.filter.id,
                        filter: updatedFilter.filter,
                        viewId: viewId
                    )
                    if filter.filter.condition != updatedFilter.filter.condition {
                        AnytypeAnalytics.instance().logChangeFilterValue(
                            condition: updatedFilter.filter.condition.stringValue,
                            objectType: setDocument.analyticsType
                        )
                    }
                } else {
                    try await dataviewService.addFilter(
                        objectId: setDocument.objectId,
                        blockId: setDocument.blockId,
                        filter: updatedFilter.filter,
                        viewId: viewId
                    )
                    AnytypeAnalytics.instance().logAddFilter(
                        condition: updatedFilter.filter.condition.stringValue,
                        objectType: setDocument.analyticsType
                    )
                }
            }
        }
    }
}
