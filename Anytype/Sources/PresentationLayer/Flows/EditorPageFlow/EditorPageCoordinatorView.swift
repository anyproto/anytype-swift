import Foundation
import SwiftUI

struct EditorPageCoordinatorView: View {
    
    @StateObject private var model: EditorPageCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    @Environment(\.dismiss) private var dismiss
    
    init(
        data: EditorPageObject,
        showHeader: Bool,
        setupEditorInput: @escaping (EditorPageModuleInput, String) -> Void
    ) {
        self._model = StateObject(wrappedValue: EditorPageCoordinatorViewModel(data: data, showHeader: showHeader, setupEditorInput: setupEditorInput))
    }
    
    var body: some View {
        EditorPageView(data: model.data, output: model, showHeader: model.showHeader)
            .ignoresSafeArea()
            .onAppear {
                model.pageNavigation = pageNavigation
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
            .sheet(item: $model.relationValueData) { data in
                RelationValueCoordinatorView(data: data, output: model)
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
            .sheet(item: $model.relationsSearchData) {
                RelationsSearchCoordinatorView(data: $0)
            }
            .anytypeSheet(item: $model.undoRedoObjectId) {
                UndoRedoView(objectId: $0.value)
            }
            .snackbar(toastBarData: $model.toastBarData)
            .openUrl(url: $model.openUrlData)
    }
}
