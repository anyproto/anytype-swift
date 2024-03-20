import SwiftUI

struct SetSortsListCoordinatorView: View {
    @StateObject var model: SetSortsListCoordinatorViewModel
    
    var body: some View {
        SetSortsListView(
            setDocument: model.setDocument,
            viewId: model.viewId,
            output: model
        )
        .sheet(item: $model.sortsSearchData) { data in
            model.setSortsSearch(data: data)
        }
        .sheet(item: $model.sortTypesData) { data in
            model.setSortTypesList(data: data)
                .fitPresentationDetents()
                .background(Color.Background.secondary)
        }
    }
}
