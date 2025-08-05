import SwiftUI

@MainActor
final class SharingExtensionCoordinatorViewModel: ObservableObject, SharingExtensionModuleOutput {
    
    @Published var showShareTo: SharingExtensionShareToData?
    
    // MARK: - SharingExtensionModuleOutput
    
    func onSelectDataSpace(spaceId: String) {
        showShareTo = SharingExtensionShareToData(spaceId: spaceId)
    }
}
