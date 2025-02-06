import SwiftUI

struct NewSettingsView: View {
    @StateObject private var model: NewSettingsViewModel
    
    init() {
        _model = StateObject(wrappedValue: NewSettingsViewModel())
    }
    
    var body: some View {
        content
            .task { await model.setupSubscriptions() }
    }
    
    private var content: some View {
        EmptyView()
    }

}

#Preview {
    NewSettingsView()
}
