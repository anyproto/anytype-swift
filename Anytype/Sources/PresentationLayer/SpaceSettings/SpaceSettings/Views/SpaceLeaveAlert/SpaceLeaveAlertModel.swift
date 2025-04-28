import Foundation
import Services

@MainActor
final class SpaceLeaveAlertModel: ObservableObject {
    
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    
    private let spaceId: String
    
    @Published var spaceName: String = ""
    @Published var toast: ToastBarData?
    
    init(spaceId: String) {
        self.spaceId = spaceId
        self.spaceName = workspaceStorage.spaceView(spaceId: spaceId)?.title ?? ""
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenLeaveSpace()
    }
    
    func onTapLeave() async throws {
        AnytypeAnalytics.instance().logLeaveSpace()
        try await workspaceService.deleteSpace(spaceId: spaceId)
        toast = ToastBarData(Loc.SpaceSettings.LeaveAlert.toast(spaceName), type: .success)
    }
}
