import SwiftUI

@MainActor
final class SharingExtensionCoordinatorViewModel: ObservableObject, SharingExtensionModuleOutput {
    
    @Published var showShareTo: SharingExtensionShareToData?
    
    // MARK: - SharingExtensionModuleOutput
    
    func onSelectDataSpce(spaceId: String) {
        showShareTo = SharingExtensionShareToData(spaceId: spaceId)
    }
}
