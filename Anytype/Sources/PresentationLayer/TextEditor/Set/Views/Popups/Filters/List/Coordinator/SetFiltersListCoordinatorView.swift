import SwiftUI

struct SetFiltersListCoordinatorView: View {
    @StateObject var model: SetFiltersListCoordinatorViewModel
    
    var body: some View {
        model.list()
            .sheet(item: $model.filtersSelectionData) { data in
                model.setFiltersSelection(data: data)
            }
            .sheet(item: $model.filtersSearchData) { data in
                model.setFiltersSearch(data: data)
            }
    }
}
