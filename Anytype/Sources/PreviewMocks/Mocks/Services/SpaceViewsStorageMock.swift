import Foundation
import Combine
import Services
import Factory

final class SpaceViewsStorageMock: SpaceViewsStorageProtocol, @unchecked Sendable {

    nonisolated static let shared = SpaceViewsStorageMock()

    var spaceView: SpaceView?
    func spaceView(spaceId: String) -> SpaceView? {
        if let spaceView {
            return spaceView
        } else {
            return allSpaceViews.first { $0.targetSpaceId == spaceId }
        }
    }

    nonisolated private init() {
        for id in 0 ..< 50 {
            self.allSpaceViews.append(SpaceView.mock(id: "\(id)"))
        }
    }

    var allSpaceViews: [SpaceView] = []
    var allSpaceViewsPublisher: AnyPublisher<[SpaceView], Never> {
        CurrentValueSubject(allSpaceViews).eraseToAnyPublisher()
    }
    func startSubscription() async {}
    func stopSubscription() async {}
    func spaceView(spaceViewId: String) -> SpaceView? { return nil }
    func spaceInfo(spaceId: String) -> AccountInfo? { return nil }
    func addSpaceInfo(spaceId: String, info: AccountInfo) {}
}
