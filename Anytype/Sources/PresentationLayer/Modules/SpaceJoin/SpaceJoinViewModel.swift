import Foundation
import Services
import AnytypeCore

struct SpaceJoinModuleData: Identifiable {
    let id = UUID()
    let cid: String
    let key: String
}

enum SpaceJoinDataState {
    case requestSent
    case invite
}

@MainActor
final class SpaceJoinViewModel: ObservableObject {
    
    private let data: SpaceJoinModuleData
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    
    private var inviteView: SpaceInviteView?
    private var onManageSpaces: () -> Void
    private var callManageSpaces = false
    
    @Published var errorMessage: String = ""
    @Published var message: String = ""
    @Published var comment: String = ""
    @Published var state: ScreenState = .loading
    @Published var dataState: SpaceJoinDataState = .invite
    @Published var toast: ToastBarData = .empty
    @Published var showSuccessAlert = false
    @Published var dismiss = false
    
    init(data: SpaceJoinModuleData, onManageSpaces: @escaping () -> Void) {
        self.data = data
        self.onManageSpaces = onManageSpaces
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
    
    func onDismissSuccessAlert() {
        dismiss.toggle()
    }
    
    func onTapManageSpaces() {
        callManageSpaces = true
        dismiss.toggle()
    }
    
    func onDisappear() {
        // Sheet open like form if at this time form sheet screen closes (anytypeSheet).
        // Notify parent after dismiss.
        if callManageSpaces {
            onManageSpaces()
        }
    }
    
    // MARK: - Private
    
    private func updateView() async {
        do {
            let inviteView = try await workspaceService.inviteView(cid: data.cid, key: data.key)
            message = Loc.SpaceShare.Join.message(inviteView.spaceName.withPlaceholder, inviteView.creatorName.withPlaceholder)
            self.inviteView = inviteView
            state = .data
            if let spaceView = workspaceStorage.allWorkspaces.first(where: { $0.targetSpaceId == inviteView.spaceId }),
                spaceView.accountStatus == .spaceJoining {
                dataState = .requestSent
            } else {
                dataState = .invite
            }
        } catch {
            errorMessage = error.localizedDescription
            state = .error
        }
    }
}
