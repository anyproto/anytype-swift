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
    case alreadyJoined
    case inviteNotFound
    case spaceDeleted
}

@MainActor
final class SpaceJoinViewModel: ObservableObject {
    
    private let data: SpaceJoinModuleData
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    
    private var inviteView: SpaceInviteView?
    private var onManageSpaces: () -> Void
    private var callManageSpaces = false
    
    @Published var errorMessage: String = ""
    @Published var message: String = Loc.SpaceShare.Join.message("", "") // For Placeholder
    @Published var state: ScreenState = .loading
    @Published var dataState: SpaceJoinDataState = .invite
    @Published var toast: ToastBarData = .empty
    @Published var showSuccessAlert = false
    @Published var dismiss = false
    
    init(data: SpaceJoinModuleData, onManageSpaces: @escaping () -> Void) {
        self.data = data
        self.onManageSpaces = onManageSpaces
    }
    
    func onJoin() async throws {
        guard let inviteView else {
            anytypeAssertionFailure("Try to join without invite")
            throw CommonError.undefined
        }
        try await workspaceService.join(
            spaceId: inviteView.spaceId,
            cid: data.cid,
            key: data.key,
            networkId: accountManager.account.info.networkId
        )
        showSuccessAlert.toggle()
    }
    
    func onDismissSuccessAlert() {
        dismiss.toggle()
    }
    
    func onDismissInviteNotFoundAlert() {
        dismiss.toggle()
    }
    
    func onTapManageSpaces() {
        callManageSpaces = true
        dismiss.toggle()
    }
    
    func onTapGoToSpace() async throws {
        guard let inviteView else { return }
        try await activeSpaceManager.setActiveSpace(spaceId: inviteView.spaceId)
        dismiss.toggle()
    }
    
    func onDisappear() {
        // Sheet open like form if at this time form sheet screen closes (anytypeSheet).
        // Notify parent after dismiss.
        if callManageSpaces {
            onManageSpaces()
        }
    }
    
    func onAppear() async {
        await updateView()
    }
    
    func onRequestSentAppear() {
        AnytypeAnalytics.instance().logScreenRequestSent()
    }
    
    func onInviewViewAppear() {
        AnytypeAnalytics.instance().logScreenInviteRequest()
    }
    
    // MARK: - Private
    
    private func updateView() async {
        do {
            let inviteView = try await workspaceService.inviteView(cid: data.cid, key: data.key)
            message = Loc.SpaceShare.Join.message(
                inviteView.spaceName.withPlaceholder.trimmingCharacters(in: .whitespaces),
                inviteView.creatorName.withPlaceholder.trimmingCharacters(in: .whitespaces)
            )
            self.inviteView = inviteView
            state = .data
            
            if let spaceView = workspaceStorage.allWorkspaces.first(where: { $0.targetSpaceId == inviteView.spaceId }) {
                switch spaceView.accountStatus {
                case .spaceJoining:
                    dataState = .requestSent
                case .spaceActive, .unknown:
                    dataState = .alreadyJoined
                default:
                    dataState = .invite
                }
            } else {
                dataState = .invite
            }
        } catch let error as SpaceInviteViewError where error.code == .inviteNotFound {
            dataState = .inviteNotFound
            state = .data
        } catch let error as SpaceInviteViewError where error.code == .spaceIsDeleted {
            dataState = .spaceDeleted
            state = .data
        } catch {
            errorMessage = error.localizedDescription
            state = .error
        }
    }
}
