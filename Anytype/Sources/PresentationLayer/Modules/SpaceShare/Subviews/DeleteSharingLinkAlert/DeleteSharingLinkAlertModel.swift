import Foundation
import Services

@MainActor
final class DeleteSharingLinkAlertModel: ObservableObject {
    
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    
    private let spaceId: String
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func onTapDeleteLink() async throws {
        try await workspaceService.revokeInvite(spaceId: spaceId)
    }
}
