import Foundation
import Services

@MainActor
final class SpaceRequestAlertModel: ObservableObject {

    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    
    private let data: SpaceRequestAlertData
    
    @Published var title = ""
    
    init(data: SpaceRequestAlertData) {
        self.data = data
        title = Loc.SpaceShare.ViewRequest.title(
            data.participantName.withPlaceholder,
            data.spaceName.withPlaceholder
        )
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
