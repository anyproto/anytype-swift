import Foundation
import Services
import AnytypeCore

@MainActor
final class SpaceJoinViewModel: ObservableObject {
    
    private let data: SpaceJoinModuleData
    private let workspaceService: WorkspaceServiceProtocol
    
    private var inviteView: SpaceInviteView?
    
    @Published var errorMessage: String = ""
    @Published var message: String = ""
    @Published var comment: String = ""
    @Published var state: ScreenState = .loading
    @Published var toast: ToastBarData = .empty
    @Published var showSuccessAlert = false
    
    init(data: SpaceJoinModuleData, workspaceService: WorkspaceServiceProtocol) {
        self.data = data
        self.workspaceService = workspaceService
        Task {
            await updateView()
        }
    }
    
    func onJoin() async throws {
        guard let inviteView else {
            anytypeAssertionFailure("Try to join without invite")
            throw CommonError.undefined
        }
        try await workspaceService.join(spaceId: inviteView.spaceId, cid: data.cid, key: data.key)
        showSuccessAlert.toggle()
    }
    
    // MARK: - Private
    
    private func updateView() async {
        do {
            let inviteView = try await workspaceService.inviteView(cid: data.cid, key: data.key)
            message = Loc.SpaceShare.Join.message(inviteView.spaceName, inviteView.creatorName)
            self.inviteView = inviteView
            state = .data
        } catch {
            errorMessage = error.localizedDescription
            state = .error
        }
    }
}
