import Foundation
import Services
import Combine

@MainActor
final class ActiveWorkspaceStorageMock: ActiveWorkspaceStorageProtocol {
    
    @MainActor
    static let shared = ActiveWorkspaceStorageMock()
    
    init() {}
    
    var workspaceInfo: AccountInfo = .empty
    var workspaceInfoPublisher: AnyPublisher<AccountInfo, Never> {
        CurrentValueSubject(workspaceInfo).eraseToAnyPublisher()
    }
    func setActiveSpace(spaceId: String) async throws {}
    func setupActiveSpace() async {}
    
    var spaceViewValue: SpaceView? = WorkspacesStorageMock.shared.activeWorkspaces.first
    func spaceView() -> SpaceView? { return spaceViewValue }
    
    func clearActiveSpace() async {}
}
