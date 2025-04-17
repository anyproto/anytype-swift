import SwiftUI

struct MigrationCoordinatorView: View {
    
    @StateObject private var model: MigrationCoordinatorViewModel
    
    init(data: MigrationModuleData) {
        self._model = StateObject(wrappedValue: MigrationCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        MigrationView(
            data: model.data,
            output: model
        )
        .sheet(isPresented: $model.showMigrationInfo) {
            MigrationReadMoreView()
        }
        .sheet(isPresented: $model.showPublicDebugMenu) {
            PublicDebugMenuView()
        }
    }
}

#Preview {
    MigrationCoordinatorView(
        data: MigrationModuleData(id: "id", onFinish: {})
    )
}
