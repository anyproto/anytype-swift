import SwiftUI

struct MigrationCoordinatorView: View {

    @State private var model: MigrationCoordinatorViewModel

    init(data: MigrationModuleData) {
        _model = State(initialValue: MigrationCoordinatorViewModel(data: data))
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
