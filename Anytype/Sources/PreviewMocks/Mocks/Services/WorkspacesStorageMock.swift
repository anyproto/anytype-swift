import Foundation
import Combine
import Services
import Factory

final class WorkspacesStorageMock: WorkspacesStorageProtocol, @unchecked Sendable {
    
    nonisolated static let shared = WorkspacesStorageMock()
    
    var spaceView: SpaceView?
    func spaceView(spaceId: String) -> SpaceView? {
        if let spaceView {
            return spaceView
        } else {
            return allWorkspaces.first { $0.targetSpaceId == spaceId }
        }
    }
    
    nonisolated private init() {
        for id in 0 ..< 50 {
            self.allWorkspaces.append(SpaceView.mock(id: "\(id)"))
        }
    }
    
    var allWorkspaces: [SpaceView] = []
    var allWorkspsacesPublisher: AnyPublisher<[SpaceView], Never> {
        CurrentValueSubject(allWorkspaces).eraseToAnyPublisher()
    }
    func startSubscription() async {}
    func stopSubscription() async {}
    func spaceView(spaceViewId: String) -> SpaceView? { return nil }
    func workspaceInfo(spaceId: String) -> AccountInfo? { return nil }
    func addWorkspaceInfo(spaceId: String, info: AccountInfo) {}
}
