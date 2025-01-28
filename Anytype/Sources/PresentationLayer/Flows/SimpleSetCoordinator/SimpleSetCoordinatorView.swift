import SwiftUI

struct SimpleSetCoordinatorView: View {
    
    @StateObject private var model: SimpleSetCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init(data: EditorSimpleSetObject) {
        self._model = StateObject(wrappedValue: SimpleSetCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        SimpleSetView(
            objectId: model.data.objectId,
            spaceId: model.data.spaceId,
            output: model
        )
        .onAppear {
            model.pageNavigation = pageNavigation
        }
    }
}

#Preview {
    SimpleSetCoordinatorView(data: EditorSimpleSetObject(objectId: "", spaceId: ""))
}
