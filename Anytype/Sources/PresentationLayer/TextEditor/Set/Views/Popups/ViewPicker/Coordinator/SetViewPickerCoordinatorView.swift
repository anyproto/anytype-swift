import SwiftUI

struct SetViewPickerCoordinatorView: View {
    @StateObject private var model: SetViewPickerCoordinatorViewModel
    
    init(data: SetViewData) {
        _model = StateObject(wrappedValue: SetViewPickerCoordinatorViewModel(data: data))
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
