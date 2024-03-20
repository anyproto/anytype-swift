import Foundation
import Services

final class SpaceCancelRequestAlertModel: ObservableObject {
    
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    
    private let spaceId: String
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func onTapCancelEquest() async throws {
        try await workspaceService.joinCancel(spaceId: spaceId)
    }
}
