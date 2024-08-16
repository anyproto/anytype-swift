import Foundation
import SwiftUI

@MainActor
final class SpaceSwitchCoordinatorViewModel: ObservableObject, SpaceSwitchModuleOutput, SpaceCreateModuleOutput {

    let data: SpaceSwitchModuleData
    
    @Published var showSpaceCreate = false
    @Published var showSettings = false
    @Published var dismiss = false

    // MARK: - SpaceSwitchModuleOutput
    
    init(data: SpaceSwitchModuleData) {
        self.data = data
    }
    
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
