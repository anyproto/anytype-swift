import SwiftUI
import Services

struct SetFiltersSelectionCoordinatorView: View {
    @StateObject var model: SetFiltersSelectionCoordinatorViewModel
    
    var body: some View {
        model.list()
            .sheet(item: $model.filterConditions) { data in
                model.setFilterConditions(data: data)
                    .fitPresentationDetents()
                    .background(Color.Background.secondary)
            }
    }
}
