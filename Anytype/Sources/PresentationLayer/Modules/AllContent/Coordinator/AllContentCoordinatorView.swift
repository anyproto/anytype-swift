import SwiftUI

struct AllContentCoordinatorView: View {
    
    @StateObject private var model: AllContentCoordinatorViewModel
    
    init(spaceId: String) {
        _model = StateObject(wrappedValue: AllContentCoordinatorViewModel(spaceId: spaceId))
    }
    
    var body: some View {
        AllContentView(spaceId: model.spaceId)
    }
}

#Preview {
    AllContentCoordinatorView(spaceId: "")
}
