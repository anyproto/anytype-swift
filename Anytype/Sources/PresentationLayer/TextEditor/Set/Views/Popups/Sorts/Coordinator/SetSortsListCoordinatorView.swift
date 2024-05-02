import SwiftUI

struct SetSortsListCoordinatorView: View {
    @StateObject private var model: SetSortsListCoordinatorViewModel
    
    init(setDocument: SetDocumentProtocol, viewId: String) {
        _model = StateObject(wrappedValue: SetSortsListCoordinatorViewModel(setDocument: setDocument, viewId: viewId))
    }
    
    var body: some View {
        SetSortsListView(
            setDocument: model.setDocument,
            viewId: model.viewId,
            output: model
        )
        .sheet(item: $model.sortsSearchData) { data in
            SetRelationsDetailsLocalSearchView(data: data)
        }
        .sheet(item: $model.sortTypesData) { data in
            CheckPopupView(viewModel: SetSortTypesListViewModel(data: data))
                .fitPresentationDetents()
                .background(Color.Background.secondary)
        }
    }
}
