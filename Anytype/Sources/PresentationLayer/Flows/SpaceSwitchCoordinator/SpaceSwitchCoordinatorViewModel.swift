import Foundation
import SwiftUI

@MainActor
final class SpaceSwitchCoordinatorViewModel: ObservableObject, SpaceSwitchModuleOutput, SpaceCreateModuleOutput {

    private let settingsCoordinator: SettingsCoordinatorProtocol
    
    @Published var showSpaceCreate = false
    @Published var dismiss = false
    
    init(settingsCoordinator: SettingsCoordinatorProtocol) {
        self.settingsCoordinator = settingsCoordinator
    }

    // MARK: - SpaceSwitchModuleOutput
    
    func onCreateSpaceSelected() {
        showSpaceCreate.toggle()
    }
    
    func onSettingsSelected() {
        settingsCoordinator.startFlow()
    }
    
    // MARK: - SpaceCreateModuleOutput
    
    func spaceCreateWillDismiss() {
        dismiss.toggle()
    }
}
