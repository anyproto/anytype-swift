import Foundation
import Services

@MainActor
final class StopSharingAlertModel: ObservableObject {
    
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    
    private let spaceId: String
    
    @Published var toast: ToastBarData = .empty
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func onTapStopShare() async throws {
        try await workspaceService.stopSharing(spaceId: spaceId)
        toast = ToastBarData(text: Loc.SpaceShare.StopSharing.toast, showSnackBar: true, messageType: .success)
    }
}
