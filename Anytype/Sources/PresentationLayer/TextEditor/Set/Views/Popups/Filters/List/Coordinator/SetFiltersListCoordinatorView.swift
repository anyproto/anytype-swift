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
            SetFiltersSelectionCoordinatorView(
                spaceId: model.data.setDocument.spaceId, 
                filter: data.filter,
                completion: data.completion
            )
        }
        .sheet(item: $model.filtersSearchData) { data in
            SetRelationsDetailsLocalSearchView(data: data)
        }
    }
}
