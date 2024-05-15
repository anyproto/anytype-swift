import Foundation
import SwiftUI

@MainActor
final class SpaceSwitchCoordinatorViewModel: ObservableObject, SpaceSwitchModuleOutput, SpaceCreateModuleOutput {

    @Published var showSpaceCreate = false
    @Published var showSettings = false
    @Published var dismiss = false

    // MARK: - SpaceSwitchModuleOutput
    
    func onCreateSpaceSelected() {
        showSpaceCreate.toggle()
    }
    
    func onSettingsSelected() {
        showSettings = true
    }
    
    // MARK: - SpaceCreateModuleOutput
    
    func spaceCreateWillDismiss() {
        dismiss.toggle()
    }
}
