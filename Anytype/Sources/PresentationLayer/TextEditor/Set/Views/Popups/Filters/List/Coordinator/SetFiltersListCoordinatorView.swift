import SwiftUI
import Services

struct SetFiltersListCoordinatorView: View {
    @StateObject private var model: SetFiltersListCoordinatorViewModel
    
    init(setDocument: some SetDocumentProtocol, viewId: String, subscriptionDetailsStorage: ObjectDetailsStorage) {
        _model = StateObject(wrappedValue: SetFiltersListCoordinatorViewModel(setDocument: setDocument, viewId: viewId, subscriptionDetailsStorage: subscriptionDetailsStorage))
    }
    
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
            SetPropertiesDetailsLocalSearchView(data: data)
        }
    }
}
