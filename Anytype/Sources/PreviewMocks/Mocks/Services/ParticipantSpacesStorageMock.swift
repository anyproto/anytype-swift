import Services
import Foundation
import Combine

final class ParticipantSpacesStorageMock: ParticipantSpacesStorageProtocol, @unchecked Sendable {

    nonisolated static let shared = ParticipantSpacesStorageMock()

    var allParticipantSpaces: [ParticipantSpaceViewData] = []
    var allParticipantSpacesPublisher: AnyPublisher<[ParticipantSpaceViewData], Never> {
        Just(allParticipantSpaces).eraseToAnyPublisher()
    }

    var spaceSharingInfo: SpaceSharingInfo? { nil }

    func startSubscription() async {}
    func stopSubscription() async {}

    nonisolated private init() {
        for _ in 0 ..< 30 {
            self.allParticipantSpaces.append(ParticipantSpaceViewData.mock(accountStatus: .spaceActive, localStatus: .ok))
        }

        for _ in 0 ..< 10 {
            self.allParticipantSpaces.append(ParticipantSpaceViewData.mock(accountStatus: .spaceJoining, localStatus: .loading))
        }
    }
}
