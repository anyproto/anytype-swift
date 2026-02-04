import SwiftUI

@MainActor
@Observable
final class MigrationCoordinatorViewModel: MigrationModuleOutput {

    @ObservationIgnored
    let data: MigrationModuleData

    var showPublicDebugMenu = false
    var showMigrationInfo = false
    
    init(data: MigrationModuleData) {
        self.data = data
    }
    
    // MARK: - MigrationModuleOutput
    
    func onReadMoreTap() {
        showMigrationInfo.toggle()
    }
    
    func onDebugTap() {
        showPublicDebugMenu.toggle()
    }
}
