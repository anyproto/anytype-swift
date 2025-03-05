import SwiftUI

struct SpaceCreateCoordinatorView: View {
    
    @StateObject private var model: SpaceCreateCoordinatorViewModel
    
    init(data: SpaceCreateData) {
        self._model = StateObject(wrappedValue: SpaceCreateCoordinatorViewModel(data: data))
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
