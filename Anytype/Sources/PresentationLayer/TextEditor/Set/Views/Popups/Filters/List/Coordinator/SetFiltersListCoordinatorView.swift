import SwiftUI

struct SetFiltersListCoordinatorView: View {
    @StateObject var model: SetFiltersListCoordinatorViewModel
    
    var body: some View {
        SetFiltersListView(
            data: model.data,
            output: model,
            subscriptionDetailsStorage: model.subscriptionDetailsStorage
        )
        .sheet(item: $model.filtersSelectionData) { data in
            model.setFiltersSelection(data: data)
        }
        .sheet(item: $model.filtersSearchData) { data in
            SetRelationsDetailsLocalSearchView(data: data)
        }
    }
}
