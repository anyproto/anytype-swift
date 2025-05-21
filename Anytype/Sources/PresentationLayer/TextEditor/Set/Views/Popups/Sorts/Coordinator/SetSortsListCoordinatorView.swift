import SwiftUI

struct SetSortsListCoordinatorView: View {
    @StateObject private var model: SetSortsListCoordinatorViewModel
    
    init(setDocument: some SetDocumentProtocol, viewId: String) {
        _model = StateObject(wrappedValue: SetSortsListCoordinatorViewModel(setDocument: setDocument, viewId: viewId))
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
