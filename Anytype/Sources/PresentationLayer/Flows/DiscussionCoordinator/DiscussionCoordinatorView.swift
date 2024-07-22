import SwiftUI

struct DiscussionCoordinatorView: View {
    
    @StateObject private var model: DiscussionCoordinatorViewModel
    
    init(data: EditorDiscussionObject) {
        self._model = StateObject(wrappedValue: DiscussionCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        DiscussionView(objectId: model.objectId, spaceId: model.spaceId, output: model)
            .sheet(item: $model.objectToMessageSearchData) {
                BlockObjectSearchView(data: $0)
            }
    }
}

#Preview {
    DiscussionCoordinatorView(data: EditorDiscussionObject(objectId: "", spaceId: ""))
}
