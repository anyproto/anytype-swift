import Foundation
import Combine
import Services
import Factory

final class WorkspacesStorageMock: WorkspacesStorageProtocol {
    
    static let shared = WorkspacesStorageMock()
    
    private init() {
        self.workspaces =  [
            SpaceView(
                id: "1",
                name: "ABC",
                title: "ABC",
                objectIconImage: .object(.space(.gradient(.random))),
                targetSpaceId: "",
                createdDate: nil,
                accountStatus: .spaceActive,
                localStatus: .spaceActive,
                spaceAccessType: .shared
            )
        ]
    }
    
    var workspaces: [SpaceView] = []
    var workspsacesPublisher: AnyPublisher<[SpaceView], Never> {
        CurrentValueSubject(workspaces).eraseToAnyPublisher()
    }
    func startSubscription() async {}
    func stopSubscription() async {}
    func spaceView(spaceViewId: String) -> SpaceView? { return nil }
    func spaceView(spaceId: String) -> SpaceView? { return nil }
    func canCreateNewSpace() -> Bool { return false }
}
