import SwiftUI

struct DateCoordinatorView: View {
    
    @StateObject private var model: DateCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init(data: EditorDateObject) {
        self._model = StateObject(wrappedValue: DateCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        DateView(
            objectId: model.objectId,
            spaceId: model.spaceId,
            output: model
        )
        .onAppear {
            model.pageNavigation = pageNavigation
        }
        .anytypeSheet(isPresented: $model.showSyncStatusInfo) {
            SyncStatusInfoView(spaceId: model.spaceId)
        }
    }
}

#Preview {
    DateCoordinatorView(data: EditorDateObject(objectId: "", spaceId: ""))
}
