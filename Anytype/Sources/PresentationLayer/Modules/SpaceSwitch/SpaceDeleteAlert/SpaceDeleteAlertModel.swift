import Foundation
import Services

@MainActor
final class SpaceDeleteAlertModel: ObservableObject {
    
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    
    private let spaceId: String
    
    @Published var spaceName: String = ""
    
    init(spaceId: String) {
        self.spaceId = spaceId
        self.spaceName = workspaceStorage.spaceView(spaceId: spaceId)?.title ?? ""
    }
    
    func onTapCancel() {
        AnytypeAnalytics.instance().logClickDeleteSpaceWarning(type: .cancel)
    }
    
    func onTapDelete() async throws {
        AnytypeAnalytics.instance().logClickDeleteSpaceWarning(type: .delete)
        try await workspaceService.deleteSpace(spaceId: spaceId)
        AnytypeAnalytics.instance().logDeleteSpace(type: .private)
    }
}
