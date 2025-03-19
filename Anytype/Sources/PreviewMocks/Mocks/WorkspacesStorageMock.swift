import Foundation
import Combine
import Services
import Factory

final class WorkspacesStorageMock: WorkspacesStorageProtocol, @unchecked Sendable {
    
    nonisolated static let shared = WorkspacesStorageMock()
    
    var spaceView: SpaceView?
    func spaceView(spaceId: String) -> SpaceView? {
        print(spaceView as Any)
        print(spaceView?.objectIconImage as Any)
        return spaceView
    }
    
    nonisolated private init() {
        self.allWorkspaces =  [
            SpaceView(
                id: "1",
                name: "ABC",
                description: "desc",
                objectIconImage: .object(.space(.name(name: "test", iconOption: 1))),
                targetSpaceId: "",
                createdDate: nil,
                accountStatus: .spaceActive,
                localStatus: .spaceActive,
                spaceAccessType: .shared,
                readersLimit: nil,
                writersLimit: nil,
                chatId: "",
                isPinned: false,
                uxType: .data
            )
        ]
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
    func canCreateNewSpace() -> Bool { true }
    func move(space: SpaceView, after: SpaceView) async { }
}
