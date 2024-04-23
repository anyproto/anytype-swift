import Foundation
import SwiftUI

struct EditorPageCoordinatorView: View {
    
    @StateObject var model: EditorPageCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        model.pageModule()
            .ignoresSafeArea()
            .onAppear {
                model.pageNavigation = pageNavigation
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
            .sheet(item: $model.relationValueData) { data in
                model.relationValueCoordinator(data: data)
            }
            .sheet(item: $model.codeLanguageData) {
                CodeLanguageListView(data: $0)
            }
            .sheet(item: $model.covertPickerData) {
                ObjectCoverPicker(data: $0)
            }
            .sheet(item: $model.linkToObjectData) {
                LinkToObjectSearchView(data: $0) { data in
                    model.showEditorScreen(data: data)
                }
            }
            .sheet(item: $model.objectIconPickerData) {
                ObjectIconPicker(data: $0)
            }
            .sheet(item: $model.textIconPickerData) {
                TextIconPickerView(data: $0)
            }
            .sheet(item: $model.blockObjectSearchData) {
                BlockObjectSearchView(data: $0)
            }
            .anytypeSheet(item: $model.undoRedoObjectId) {
                UndoRedoView(objectId: $0.value)
            }
            .snackbar(toastBarData: $model.toastBarData)
    }
}
