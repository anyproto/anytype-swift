import SwiftUI
import BlocksModels

final class SetFiltersSearchViewModel: ObservableObject {
    let onSelect: (_ ids: [String]) -> Void
    let headerConfiguration: SetFiltersSearchHeaderConfiguration
    private let filter: SetFilter
    private let searchViewBuilder: SetFiltersSearchViewBuilder
    
    init(
        filter: SetFilter,
        onSelect: @escaping (_ ids: [String]) -> Void)
    {
        self.onSelect = onSelect
        self.filter = filter
        self.searchViewBuilder = SetFiltersSearchViewBuilder(filter: filter)
        self.headerConfiguration = SetFiltersSearchHeaderConfiguration(
            id: filter.id,
            title: filter.metadata.name,
            condition: filter.conditionString ?? "",
            iconName: filter.metadata.format.iconName,
            onConditionTap: {}
        )
    }
    
    @ViewBuilder
    func makeSearchView() -> some View {
        searchViewBuilder.buildSearchView(
            onSelect: onSelect
        )
    }
}
