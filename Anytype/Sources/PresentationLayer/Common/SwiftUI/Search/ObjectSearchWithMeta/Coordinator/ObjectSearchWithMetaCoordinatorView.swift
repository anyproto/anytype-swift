import SwiftUI

struct ObjectSearchWithMetaCoordinatorView: View {
    
    @StateObject private var model: ObjectSearchWithMetaCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: ObjectSearchWithMetaModuleData) {
        self._model = StateObject(wrappedValue: ObjectSearchWithMetaCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        ObjectSearchWithMetaView(
            data: model.data,
            output: model
        )
        .sheet(item: $model.newLinkedObject) {
            ChatCreateObjectCoordinatorView(
                data: $0,
                onDismiss: { result in
                    model.handleDismissResult(result)
                }
            )
        }
        .onChange(of: model.dismiss) { _ in dismiss() }
    }
}

#Preview {
    ObjectSearchWithMetaCoordinatorView(
        data: ObjectSearchWithMetaModuleData(spaceId: "", type: .pages, excludedObjectIds: [], onSelect: { _ in })
    )
}
