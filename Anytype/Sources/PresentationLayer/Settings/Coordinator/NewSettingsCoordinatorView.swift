import SwiftUI

struct NewSettingsCoordinatorView: View {
    @StateObject private var model: NewSettingsCoordinatorViewModel
    
    init() {
        _model = StateObject(wrappedValue: NewSettingsCoordinatorViewModel())
    }
    
    var body: some View {
        NewSettingsView()
            .task { await model.setupSubscriptions() }
    }
    
    private var content: some View {
        EmptyView()
    }

}

#Preview {
    NewSettingsCoordinatorView()
}
