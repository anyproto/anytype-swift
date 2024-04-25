import Foundation
import SwiftUI

@MainActor
final class SpaceSwitchCoordinatorViewModel: ObservableObject, SpaceSwitchModuleOutput, SpaceCreateModuleOutput {

    private let settingsCoordinatorAssembly: SettingsCoordinatorAssemblyProtocol
    
    @Published var showSpaceCreate = false
    @Published var showSettings = false
    @Published var dismiss = false
    
    init(settingsCoordinatorAssembly: SettingsCoordinatorAssemblyProtocol) {
        self.settingsCoordinatorAssembly = settingsCoordinatorAssembly
    }

    // MARK: - SpaceSwitchModuleOutput
    
    func onCreateSpaceSelected() {
        showSpaceCreate.toggle()
    }
    
    func onSettingsSelected() {
        showSettings = true
    }
    
    func settingsView() -> AnyView {
        settingsCoordinatorAssembly.make()
    }
    
    // MARK: - SpaceCreateModuleOutput
    
    func spaceCreateWillDismiss() {
        dismiss.toggle()
    }
}
