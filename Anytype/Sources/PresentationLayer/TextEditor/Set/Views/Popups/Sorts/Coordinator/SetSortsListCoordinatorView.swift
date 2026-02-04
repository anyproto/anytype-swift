import SwiftUI

struct SetSortsListCoordinatorView: View {
    @State private var model: SetSortsListCoordinatorViewModel

    init(setDocument: some SetDocumentProtocol, viewId: String) {
        _model = State(initialValue: SetSortsListCoordinatorViewModel(setDocument: setDocument, viewId: viewId))
    }
    
    var body: some View {
        SetSortsListView(
            setDocument: model.setDocument,
            viewId: model.viewId,
            output: model
        )
        .sheet(item: $model.sortsSearchData) { data in
            SetPropertiesDetailsLocalSearchView(data: data)
        }
        .sheet(item: $model.sortTypesData) { data in
            SetSortTypesListView(data: data)
                .fitPresentationDetents()
        }
    }
}
