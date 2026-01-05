import SwiftUI

struct SetFiltersDateCoordinatorView: View {
    @State private var model: SetFiltersDateCoordinatorViewModel

    init(data: SetFiltersDateViewData, setSelectionModel: SetFiltersSelectionViewModel?) {
        _model = State(initialValue: SetFiltersDateCoordinatorViewModel(data: data, setSelectionModel: setSelectionModel))
    }
    
    var body: some View {
        SetFiltersDateView(
            data: model.data,
            setSelectionModel: model.setSelectionModel
        )
        .sheet(item: $model.filtersDaysData) { data in
            SetTextView(data: data)
        }
    }
}
