import Foundation
import Services
import Combine

@MainActor
final class ActiveWorkpaceStorageMock: ActiveWorkpaceStorageProtocol {
    
    @MainActor
    static let shared = ActiveWorkpaceStorageMock()
    
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
