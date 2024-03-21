import Foundation
import Services
import AnytypeCore

struct SpaceJoinModuleData: Identifiable {
    let id = UUID()
    let cid: String
    let key: String
}

@MainActor
final class SpaceJoinViewModel: ObservableObject {
    
    private let data: SpaceJoinModuleData
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    
    private var inviteView: SpaceInviteView?
    
    @Published var errorMessage: String = ""
    @Published var message: String = ""
    @Published var comment: String = ""
    @Published var state: ScreenState = .loading
    @Published var toast: ToastBarData = .empty
    @Published var showSuccessAlert = false
    
    init(data: SpaceJoinModuleData) {
        self.data = data
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
