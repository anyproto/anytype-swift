import SwiftUI

struct SetViewPickerCoordinatorView: View {
    @StateObject var model: SetViewPickerCoordinatorViewModel
    
    var body: some View {
        model.list()
            .sheet(isPresented: $model.showSetSettings) {
                model.setSettingsView()
                    .mediumPresentationDetents()
            }
    }
}
