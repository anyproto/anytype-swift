import Foundation
import Services

final class SpaceJoinViewModel: ObservableObject {
    
    private let data: SpaceJoinModuleData
    private let workspaceService: WorkspaceServiceProtocol
    
    private var inviteView: SpaceInviteView?
    
    @Published var errorMessage: String = ""
    @Published var message: String = ""
    @Published var comment: String = ""
    @Published var state: ScreenState = .loading
    
    init(data: SpaceJoinModuleData, workspaceService: WorkspaceServiceProtocol) {
        self.data = data
        self.workspaceService = workspaceService
        Task {
            await updateView()
        }
    }
    
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
