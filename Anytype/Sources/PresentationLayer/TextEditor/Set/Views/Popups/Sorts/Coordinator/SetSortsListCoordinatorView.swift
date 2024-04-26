import SwiftUI

struct SetSortsListCoordinatorView: View {
    @StateObject var model: SetSortsListCoordinatorViewModel
    
    var body: some View {
        model.list()
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
