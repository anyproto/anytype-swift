import SwiftUI
import BlocksModels

final class SetFiltersSearchViewModel: ObservableObject {
    let headerViewModel: SetFiltersSearchHeaderViewModel
    let onApply: (SetFilter) -> Void
    private let filter: SetFilter
    private var condition: DataviewFilter.Condition

    private let searchViewBuilder: SetFiltersSearchViewBuilder
    private let router: EditorRouterProtocol
    
    init(
        filter: SetFilter,
        router: EditorRouterProtocol,
        onApply: @escaping (SetFilter) -> Void
    ) {
        self.filter = filter
        self.router = router
        self.searchViewBuilder = SetFiltersSearchViewBuilder(filter: filter)
        self.onApply = onApply
        self.condition = filter.filter.condition
        self.headerViewModel = SetFiltersSearchHeaderViewModel(filter: filter, router: router)
        self.setup()
    }
    
    @ViewBuilder
    func makeSearchView() -> some View {
        searchViewBuilder.buildSearchView(
            onSelect: { [weak self] ids in
                self?.handleSelectedIds(ids)
            }
        )
    }
    
    private func setup() {
        headerViewModel.onConditionChanged = { [weak self] condition in
            self?.updateCondition(condition)
        }
    }
    
    private func updateCondition(_ condition: DataviewFilter.Condition) {
        self.condition = condition
    }
    
    private func handleSelectedIds(_ ids: [String]) {
        let filter = SetFilter(
            metadata: filter.metadata,
            filter: DataviewFilter(
                relationKey: filter.metadata.id,
                condition: condition,
                value: ids.protobufValue
            )
        )
        onApply(filter)
    }
}
