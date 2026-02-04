import SwiftUI

@MainActor
@Observable
final class SharingExtensionCoordinatorViewModel: SharingExtensionModuleOutput, SharingExtensionShareToModuleOutput {

    var showShareTo: SharingExtensionShareToData?
    var dismiss = false
    
    // MARK: - SharingExtensionModuleOutput
    
    func onSelectDataSpace(spaceId: String) {
        showShareTo = SharingExtensionShareToData(spaceId: spaceId)
    }
    
    // MARK: - SharingExtensionShareToModuleOutput
    
    func shareToFinished() {
        dismiss.toggle()
    }
}
