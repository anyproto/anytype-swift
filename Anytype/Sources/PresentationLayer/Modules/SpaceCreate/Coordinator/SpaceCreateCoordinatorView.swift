import SwiftUI

struct SpaceCreateCoordinatorView: View {

    @State private var model: SpaceCreateCoordinatorViewModel

    init(data: SpaceCreateData) {
        _model = State(initialValue: SpaceCreateCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        SpaceCreateView(
            data: model.data,
            output: model
        )
        .sheet(item: $model.localObjectIconPickerData) {
            LocalObjectIconPickerView(data: $0)
        }
    }
}
