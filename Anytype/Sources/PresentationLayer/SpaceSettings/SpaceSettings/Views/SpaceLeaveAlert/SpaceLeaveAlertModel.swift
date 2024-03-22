import Foundation
import Services

@MainActor
final class SpaceLeaveAlertModel: ObservableObject {
    
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    
    private let spaceId: String
    
    @Published var spaceName: String = ""
    @Published var toast: ToastBarData = .empty
    
    init(spaceId: String) {
        self.spaceId = spaceId
        self.spaceName = workspaceStorage.spaceView(spaceId: spaceId)?.name ?? ""
    }
    
    func onTapLeave() async throws {
        try await workspaceService.deleteSpace(spaceId: spaceId)
        toast = ToastBarData(text: Loc.SpaceSettings.LeaveAlert.toast(spaceName), showSnackBar: true, messageType: .success)
    }
}
