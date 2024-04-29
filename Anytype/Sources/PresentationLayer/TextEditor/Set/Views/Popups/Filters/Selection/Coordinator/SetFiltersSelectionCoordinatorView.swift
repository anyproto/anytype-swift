import SwiftUI
import Services

struct SetFiltersSelectionCoordinatorView: View {
    @StateObject private var model: SetFiltersSelectionCoordinatorViewModel
    
    init(spaceId: String, filter: SetFilter, completion: @escaping (SetFilter) -> Void) {
        _model = StateObject(wrappedValue: SetFiltersSelectionCoordinatorViewModel(spaceId: spaceId, filter: filter, completion: completion))
    }
    
    var body: some View {
        SetFiltersSelectionView(
            data: model.data,
            contentViewBuilder: model.contentViewBuilder,
            output: model
        )
        .sheet(item: $model.filterConditions) { data in
            CheckPopupView(viewModel: SetFilterConditionsViewModel(data: data))
                .background(Color.Background.secondary)
                .fitPresentationDetents()
        }
    }
}
