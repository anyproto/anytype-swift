import Foundation
import SwiftUI

struct EditorSetCoordinatorView: View {
    
    @StateObject var model: EditorSetCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        model.setModule()
            .onAppear {
                model.pageNavigation = pageNavigation
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
            .sheet(item: $model.setQueryData) { data in
                model.setQuery(data)
            }
            .sheet(item: $model.relationValueData) { data in
                model.relationValueCoordinator(data: data)
            }
            .anytypeSheet(item: $model.setViewPickerData) { data in
                model.setViewPicker(data: data)
            }
            .anytypeSheet(item: $model.setViewSettingsData) { data in
                model.setViewSettings(data: data)
            }
            .sheet(item: $model.covertPickerData) {
                ObjectCoverPicker(data: $0)
            }
            .sheet(item: $model.objectIconPickerData) {
                ObjectIconPicker(data: $0)
            }
            .snackbar(toastBarData: $model.toastBarData)
    }
}
