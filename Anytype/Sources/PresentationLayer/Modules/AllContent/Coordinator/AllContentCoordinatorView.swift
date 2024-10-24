import SwiftUI

struct AllContentCoordinatorView: View {
    
    @StateObject private var model: AllContentCoordinatorViewModel
    
    init(spaceId: String, output: (any WidgetObjectListCommonModuleOutput)?) {
        _model = StateObject(wrappedValue: AllContentCoordinatorViewModel(spaceId: spaceId, output: output))
    }
    
    var body: some View {
        AllContentView(
            spaceId: model.spaceId,
            output: model
        )
    }
}

#Preview {
    AllContentCoordinatorView(spaceId: "", output: nil)
}
