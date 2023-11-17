import SwiftUI

struct SetViewPickerCoordinatorView: View {
    @StateObject var model: SetViewPickerCoordinatorViewModel
    
    var body: some View {
        model.list()
            .sheet(item: $model.setSettingsData) { data in
                model.setSettingsView(data: data)
                    .mediumPresentationDetents()
                    .background(Color.Background.secondary)
            }
    }
}
