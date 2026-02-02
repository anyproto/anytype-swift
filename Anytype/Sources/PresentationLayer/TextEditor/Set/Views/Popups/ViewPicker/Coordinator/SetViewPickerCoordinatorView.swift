import SwiftUI

struct SetViewPickerCoordinatorView: View {
    @State private var model: SetViewPickerCoordinatorViewModel

    init(data: SetViewData) {
        _model = State(initialValue: SetViewPickerCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        SetViewPicker(
            setDocument: model.setDocument,
            output: model
        )
        .sheet(item: $model.setSettingsData) { data in
            SetViewSettingsCoordinatorView(data: data)
                .mediumPresentationDetents()
                .background(Color.Background.secondary)
        }
    }
}
