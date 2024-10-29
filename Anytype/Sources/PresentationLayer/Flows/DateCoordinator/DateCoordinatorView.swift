import SwiftUI

struct DateCoordinatorView: View {
    
    @StateObject private var model: DateCoordinatorViewModel
    
    init(data: EditorDateObject) {
        self._model = StateObject(wrappedValue: DateCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        DateView(objectId: model.objectId, spaceId: model.spaceId)
    }
}

#Preview {
    DateCoordinatorView(data: EditorDateObject(objectId: "", spaceId: ""))
}
