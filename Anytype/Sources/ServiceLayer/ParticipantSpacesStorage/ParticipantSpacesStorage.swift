import Foundation
import Combine
import Services

@MainActor
protocol ParticipantSpacesStorageProtocol: AnyObject {
    var participantSpaces: [ParticipantSpaceView] { get }
    var participantSpacesPublisher: AnyPublisher<[ParticipantSpaceView], Never> { get }
    func startSubscription() async
    func stopSubscription() async
}

@MainActor
final class ParticipantSpacesStorage: ParticipantSpacesStorageProtocol {
    
    // MARK: - DI
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: AccountParticipantsStorageProtocol
    
    private var subscriptions: [AnyCancellable] = []
    
    // MARK: - State
    
    @Published private(set) var  participantSpaces: [ParticipantSpaceView] = []
    var participantSpacesPublisher: AnyPublisher<[ParticipantSpaceView], Never> { $participantSpaces.eraseToAnyPublisher() }
    
    nonisolated init() {}
    
    func startSubscription() async {
        Publishers.CombineLatest(workspaceStorage.workspsacesPublisher, accountParticipantsStorage.participantsPublisher)
            .sink { [weak self] spaces, participants in
                self?.participantSpaces = spaces.compactMap { space in
                    guard let participant = participants.first(where:  { $0.spaceId == space.targetSpaceId }) else { return nil }
                    return ParticipantSpaceView(
                        spaceView: space,
                        participant: participant
                    )
                }
            }
            .store(in: &subscriptions)
    }
    
    func stopSubscription() async {
        subscriptions.removeAll()
    }
}
