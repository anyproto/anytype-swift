import Foundation
import SwiftUI

@MainActor
final class SpaceSwitchCoordinatorViewModel: ObservableObject, SpaceSwitchModuleOutput, SpaceCreateModuleOutput {

    private let spaceSwitchModuleAssembly: SpaceSwitchModuleAssemblyProtocol
    private let spaceCreateModuleAssembly: SpaceCreateModuleAssemblyProtocol
    private let settingsCoordinator: SettingsCoordinatorProtocol
    
    @Published var showSpaceCreate = false
    @Published var dismiss = false
    
    init(
        spaceSwitchModuleAssembly: SpaceSwitchModuleAssemblyProtocol,
        spaceCreateModuleAssembly: SpaceCreateModuleAssemblyProtocol,
        settingsCoordinator: SettingsCoordinatorProtocol
    ) {
        self.spaceSwitchModuleAssembly = spaceSwitchModuleAssembly
        self.spaceCreateModuleAssembly = spaceCreateModuleAssembly
        self.settingsCoordinator = settingsCoordinator
    }
    
    func spaceSwitchModule() -> AnyView {
        return spaceSwitchModuleAssembly.make(output: self)
    }
    
    func spaceCreateModule() -> AnyView {
        return spaceCreateModuleAssembly.make(output: self)
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
