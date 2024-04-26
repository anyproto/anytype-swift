import Foundation
import Combine
import Services
import Factory

final class WorkspacesStorageMock: WorkspacesStorageProtocol {
    
    static let shared = WorkspacesStorageMock()
    
    private init() {
        self.allWorkspaces =  [
            SpaceView(
                id: "1",
                name: "ABC",
                objectIconImage: .object(.space(.gradient(.random))),
                targetSpaceId: "",
                createdDate: nil,
                accountStatus: .spaceActive,
                localStatus: .spaceActive,
                spaceAccessType: .shared,
                readersLimit: nil,
                writersLimit: nil,
                sharedSpacesLimit: nil
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
    func spaceView(spaceId: String) -> SpaceView? { return nil }
    func canCreateNewSpace() -> Bool { return false }
}
