import Foundation
import Services

@MainActor
final class DeleteSharingLinkAlertModel: ObservableObject {
    
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    
    private let spaceId: String
    private let onDelete: (() -> Void)?
    
    init(spaceId: String, onDelete: (() -> Void)?) {
        self.spaceId = spaceId
        self.onDelete = onDelete
    }
    
    func onTapDeleteLink() async throws {
        AnytypeAnalytics.instance().logClickSettingsSpaceShare(type: .revoke)
        try await workspaceService.revokeInvite(spaceId: spaceId)
        onDelete?()
    }
}
