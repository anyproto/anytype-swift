import Foundation
import SwiftUI

struct ObjectSettingsCoordinatorView: View {
    
    @StateObject private var model: ObjectSettingsCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dismissAllPresented) private var dismissAllPresented
    
    init(objectId: String, output: ObjectSettingsCoordinatorOutput?) {
        self._model = StateObject(wrappedValue: ObjectSettingsCoordinatorViewModel(objectId: objectId, output: output))
    }
    
    var body: some View {
        ObjectSettingsView(objectId: model.objectId, output: model)
            .onAppear {
                model.setDismissAllPresented(dismissAllPresented: dismissAllPresented)
            }
            .sheet(item: $model.coverPickerData) {
                ObjectCoverPicker(data: $0)
            }
            .sheet(item: $model.objectIconPickerData) {
                ObjectIconPicker(data: $0)
            }
            .sheet(item: $model.layoutPickerObjectId) {
                ObjectLayoutPicker(objectId: $0.value)
            }
            .sheet(item: $model.blockObjectSearchData) {
                BlockObjectSearchView(data: $0)
            }
            .sheet(item: $model.relationsListData) {
                RelationsListCoordinatorView(document: $0.document, output: model)
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
    }
}
