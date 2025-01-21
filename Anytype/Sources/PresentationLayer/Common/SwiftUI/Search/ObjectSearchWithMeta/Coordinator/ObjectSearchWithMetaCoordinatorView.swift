import SwiftUI

struct ObjectSearchWithMetaCoordinatorView: View {
    
    @StateObject private var model: ObjectSearchWithMetaCoordinatorViewModel
    
    init(data: ObjectSearchWithMetaModuleData) {
        self._model = StateObject(wrappedValue: ObjectSearchWithMetaCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        ObjectSearchWithMetaView(
            data: model.data
        )
    }
}

#Preview {
    ObjectSearchWithMetaCoordinatorView(
        data: ObjectSearchWithMetaModuleData(spaceId: "", title: "Attach Page", section: .pages, excludedObjectIds: [], onSelect: { _ in })
    )
}
