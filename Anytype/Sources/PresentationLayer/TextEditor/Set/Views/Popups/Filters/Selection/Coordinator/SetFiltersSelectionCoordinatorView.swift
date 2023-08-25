import SwiftUI
import Services

struct SetFiltersSelectionCoordinatorView: View {
    @StateObject var model: SetFiltersSelectionCoordinatorViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            model.header()
            model.list()
        }
        .sheet(item: $model.filterConditions) { data in
            model.setFilterConditions(data: data)
                .fitPresentationDetents()
        }
    }
}
