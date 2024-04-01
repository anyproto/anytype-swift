import SwiftUI
import Services

struct SetFiltersSelectionCoordinatorView: View {
    @StateObject var model: SetFiltersSelectionCoordinatorViewModel
    
    var body: some View {
        model.list()
            .sheet(item: $model.filterConditions) { data in
                CheckPopupView(viewModel: SetFilterConditionsViewModel(data: data))
                    .background(Color.Background.secondary)
                    .fitPresentationDetents()
            }
    }
}
