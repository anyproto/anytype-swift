import Foundation
import Services

@MainActor
final class SpaceRequestAlertModel: ObservableObject {

    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    @Injected(\.participantService)
    private var participantService: ParticipantServiceProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    
    private let data: SpaceRequestAlertData
    
    @Published var title = ""
    @Published var canAddReaded = false
    @Published var canAddWriter = false
    
    init(data: SpaceRequestAlertData) {
        self.data = data
        title = Loc.SpaceShare.ViewRequest.title(
            data.participantName.withPlaceholder,
            data.spaceName.withPlaceholder
        )
    }
    
    func onAppear() async throws {
        guard let spaceView = workspaceStorage.spaceView(spaceId: data.spaceId) else {
            throw CommonError.undefined
        }
        // Don't use participant from active subscription, because active space and space for request can be different
        let participants = try await participantService.searchParticipants(spaceId: data.spaceId)
        
        canAddReaded = spaceView.canAddReaders(participants: participants)
        canAddWriter = spaceView.canAddWriters(participants: participants)
    }
    
    func onViewAccess() async throws {
        try await workspaceService.requestApprove(
            spaceId: data.spaceId,
            identity: data.participantIdentity,
            permissions: .reader
        )
    }
    
    func onEditAccess() async throws {
        try await workspaceService.requestApprove(
            spaceId: data.spaceId,
            identity: data.participantIdentity,
            permissions: .writer
        )
    }

    func onReject() async throws {
        try await workspaceService.requestDecline(
            spaceId: data.spaceId,
            identity: data.participantIdentity
        )
    }
}
