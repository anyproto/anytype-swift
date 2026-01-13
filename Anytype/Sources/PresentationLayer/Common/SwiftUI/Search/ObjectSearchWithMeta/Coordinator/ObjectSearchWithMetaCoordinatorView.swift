import SwiftUI

struct ObjectSearchWithMetaCoordinatorView: View {

    @State private var model: ObjectSearchWithMetaCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss

    init(data: ObjectSearchWithMetaModuleData) {
        self._model = State(initialValue: ObjectSearchWithMetaCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        ObjectSearchWithMetaView(
            data: model.data
        )
        .onChange(of: model.dismiss) { dismiss() }
    }
}

#Preview {
    ObjectSearchWithMetaCoordinatorView(
        data: ObjectSearchWithMetaModuleData(spaceId: "", excludedObjectIds: [], onSelect: { _ in })
    )
}
