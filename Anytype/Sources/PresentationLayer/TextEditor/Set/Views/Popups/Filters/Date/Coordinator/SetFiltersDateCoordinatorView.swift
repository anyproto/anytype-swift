import SwiftUI

struct SetFiltersDateCoordinatorView: View {
    @StateObject private var model: SetFiltersDateCoordinatorViewModel
    
    init(data: SetFiltersDateViewData, setSelectionModel: SetFiltersSelectionViewModel?) {
        _model = StateObject(wrappedValue: SetFiltersDateCoordinatorViewModel(data: data, setSelectionModel: setSelectionModel))
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
