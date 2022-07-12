import SwiftUI
import BlocksModels

final class SetFiltersSearchViewModel: ObservableObject {
    @Published var state: SetFiltersSearchViewState
    
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
        self.state = filter.filter.condition.hasValues ? .content : .empty
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
    
    func handleSelectedIds(_ ids: [String]) {
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
    
    private func setup() {
        headerViewModel.onConditionChanged = { [weak self] condition in
            self?.updateState(with: condition)
        }
    }
    
    private func updateState(with condition: DataviewFilter.Condition) {
        self.condition = condition
        self.state = condition.hasValues ? .content : .empty
    }
}
