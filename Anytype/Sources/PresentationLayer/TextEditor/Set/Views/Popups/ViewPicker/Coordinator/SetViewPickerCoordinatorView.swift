import SwiftUI

struct SetViewPickerCoordinatorView: View {
    @StateObject var model: SetViewPickerCoordinatorViewModel
    
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
