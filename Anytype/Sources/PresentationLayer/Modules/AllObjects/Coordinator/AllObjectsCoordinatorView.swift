import SwiftUI

struct AllObjectsCoordinatorView: View {
    
    @StateObject private var model: AllObjectsCoordinatorViewModel
    
    init(spaceId: String, output: (any WidgetObjectListCommonModuleOutput)?) {
        _model = StateObject(wrappedValue: AllObjectsCoordinatorViewModel(spaceId: spaceId, output: output))
    }
    
    var body: some View {
        AllObjectsView(
            spaceId: model.spaceId,
            output: model
        )
    }
}

#Preview {
    AllObjectsCoordinatorView(spaceId: "", output: nil)
}
