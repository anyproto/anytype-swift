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
    case invite(withoutApprove: Bool)
    case alreadyJoined
    case inviteNotFound
    case spaceDeleted
    case limitReached
    
    var inviteWithoutApprove: Bool {
        switch self {
        case let .invite(withoutApprove):
            return withoutApprove
        default:
            return false
        }
    }
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
    @Published var title: String = Loc.SpaceShare.Join.title
    @Published var message: String = Loc.SpaceShare.Join.message("", "") // For Placeholder
    @Published var button: String = Loc.SpaceShare.Join.button
    @Published var state: ScreenState = .loading
    @Published var dataState: SpaceJoinDataState = .invite(withoutApprove: false)
    @Published var toast: ToastBarData?
    @Published var showSuccessAlert = false
    @Published var joinTaskId: String?
    @Published var dismiss = false
    
    init(data: SpaceJoinModuleData, onManageSpaces: @escaping () -> Void) {
        self.data = data
        self.onManageSpaces = onManageSpaces
    }
    
    func onJoinTapped() {
        joinTaskId = UUID().uuidString
    }
    
    func onJoin() async {
        guard let inviteView else {
            anytypeAssertionFailure("Try to join without invite")
            return
        }
        do {
            try await workspaceService.join(
                spaceId: inviteView.spaceId,
                cid: data.cid,
                key: data.key,
                networkId: accountManager.account.info.networkId
            )
            if inviteView.inviteType.withoutApprove {
                dismiss.toggle()
            } else {
                showSuccessAlert.toggle()
            }
        } catch let error as SpaceJoinError where error.code == .limitReached {
            dataState = .limitReached
            state = .data
        } catch {
            errorMessage = error.localizedDescription
            state = .error
        }
    }
    
    func onCancel() {
        dismiss.toggle()
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
        let type: ScreenInviteRequestType = dataState.inviteWithoutApprove ? .withoutApproval : .approval
        AnytypeAnalytics.instance().logScreenInviteRequest(type: type)
    }
    
    // MARK: - Private
    
    private func updateView() async {
        do {
            let inviteView = try await workspaceService.inviteView(cid: data.cid, key: data.key)
            
            handleInviteType(inviteView: inviteView)
            
            self.inviteView = inviteView
            state = .data
            
            let inviteWithoutApprove = inviteView.inviteType.withoutApprove
            if let spaceView = workspaceStorage.allWorkspaces.first(where: { $0.targetSpaceId == inviteView.spaceId }) {
                switch spaceView.accountStatus {
                case .spaceJoining:
                    dataState = .requestSent
                case .spaceActive, .unknown:
                    dataState = .alreadyJoined
                default:
                    dataState = .invite(withoutApprove: inviteWithoutApprove)
                }
            } else {
                dataState = .invite(withoutApprove: inviteWithoutApprove)
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
    
    private func handleInviteType(inviteView: SpaceInviteView) {
        if inviteView.inviteType.withoutApprove {
            let spaceName = inviteView.spaceName.withPlaceholder.trimmingCharacters(in: .whitespaces)
            title = Loc.SpaceShare.Join.NoApprove.title(spaceName)
            message = Loc.SpaceShare.Join.NoApprove.message(
                spaceName,
                inviteView.creatorName.withPlaceholder.trimmingCharacters(in: .whitespaces)
            )
            button = Loc.SpaceShare.Join.NoApprove.button
        } else {
            title = Loc.SpaceShare.Join.title
            message = Loc.SpaceShare.Join.message(
                inviteView.spaceName.withPlaceholder.trimmingCharacters(in: .whitespaces),
                inviteView.creatorName.withPlaceholder.trimmingCharacters(in: .whitespaces)
            )
            button = Loc.SpaceShare.Join.button
        }
    }
}
