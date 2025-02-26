import SwiftUI

struct ObjectTypeCoordinator: View {
    @StateObject private var model: ObjectTypeCoordinatorModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init(data: EditorTypeObject) {
        _model = StateObject(wrappedValue: ObjectTypeCoordinatorModel(data: data))
    }
    
    var body: some View {
        ObjectTypeView(document: model.document, output: model)
            .onAppear { model.pageNavigation = pageNavigation }
        
            .anytypeSheet(isPresented: $model.showSyncStatusInfo) {
                SyncStatusInfoView(spaceId: model.document.spaceId)
            }
            .sheet(item: $model.objectIconPickerData) {
                ObjectIconPicker(data: $0)
            }
            .sheet(item: $model.layoutPickerObjectId) {
                ObjectLayoutPicker(mode: .type, objectId: $0.value, spaceId: model.document.spaceId, analyticsType: model.document.details?.analyticsType ?? .custom)
            }
            .sheet(isPresented: $model.showTypeFields) {
                TypeFieldsView(document: model.document)
            }
    }
}

#Preview {
    ObjectTypeCoordinator(data: EditorTypeObject(objectId: "", spaceId: ""))
}
