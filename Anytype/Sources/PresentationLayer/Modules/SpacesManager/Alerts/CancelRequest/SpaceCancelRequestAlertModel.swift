import Foundation
import Services

@MainActor
final class SpaceCancelRequestAlertModel: ObservableObject {
    
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    
    private let spaceId: String
    
    @Published var toast: ToastBarData = .empty
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func onTapCancelEquest() async throws {
        try await workspaceService.joinCancel(spaceId: spaceId)
        toast = ToastBarData(text: Loc.SpaceManager.CancelRequestAlert.toast, showSnackBar: true, messageType: .success)
    }
}
