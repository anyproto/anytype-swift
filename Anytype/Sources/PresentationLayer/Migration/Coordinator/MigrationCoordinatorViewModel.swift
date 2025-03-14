import SwiftUI

@MainActor
final class MigrationCoordinatorViewModel: ObservableObject, MigrationModuleOutput {
    
    let data: MigrationModuleData
    
    @Published var showPublicDebugMenu = false
    @Published var showMigrationInfo = false
    
    init(data: MigrationModuleData) {
        self.data = data
    }
    
    // MARK: - MigrationModuleOutput
    
    func onReadMoreTap() {
        
    }
    
    func onDebugTap() {
        showPublicDebugMenu.toggle()
    }
}
