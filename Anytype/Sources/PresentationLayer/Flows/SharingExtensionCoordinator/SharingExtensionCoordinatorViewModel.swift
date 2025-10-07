import SwiftUI

@MainActor
final class SharingExtensionCoordinatorViewModel: ObservableObject, SharingExtensionModuleOutput, SharingExtensionShareToModuleOutput {
    
    @Published var showShareTo: SharingExtensionShareToData?
    @Published var dismiss = false
    
    // MARK: - SharingExtensionModuleOutput
    
    func onSelectDataSpace(spaceId: String) {
        showShareTo = SharingExtensionShareToData(spaceId: spaceId)
    }
    
    // MARK: - SharingExtensionShareToModuleOutput
    
    func shareToFinished() {
        dismiss.toggle()
    }
}
