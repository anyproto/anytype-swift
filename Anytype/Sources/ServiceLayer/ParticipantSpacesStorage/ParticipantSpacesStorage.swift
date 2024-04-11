import Foundation
import Combine
import Services

@MainActor
protocol ParticipantSpacesStorageProtocol: AnyObject {
    var allParticipantSpaces: [ParticipantSpaceView] { get }
    var allParticipantSpacesPublisher: AnyPublisher<[ParticipantSpaceView], Never> { get }
    func canShareSpace() -> Bool
    
    func startSubscription() async
    func stopSubscription() async
}

extension ParticipantSpacesStorageProtocol {
    
    var activeParticipantSpaces: [ParticipantSpaceView] {
        allParticipantSpaces.filter(\.spaceView.isActive)
    }
    
    var activeParticipantSpacesPublisher: AnyPublisher<[ParticipantSpaceView], Never> {
        allParticipantSpacesPublisher.map { $0.filter(\.spaceView.isActive) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

@MainActor
final class ParticipantSpacesStorage: ParticipantSpacesStorageProtocol {
    
    private enum Constants {
        static let maxSharedSpaces = 3
    }
    
    // MARK: - DI
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: AccountParticipantsStorageProtocol
    
    private var subscriptions: [AnyCancellable] = []
    
    // MARK: - State
    
    @Published private(set) var allParticipantSpaces: [ParticipantSpaceView] = []
    var allParticipantSpacesPublisher: AnyPublisher<[ParticipantSpaceView], Never> { $allParticipantSpaces.eraseToAnyPublisher() }
    
    nonisolated init() {}
    
    func canShareSpace() -> Bool {
        allParticipantSpaces.filter { $0.spaceView.isActive && $0.spaceView.isShared && $0.isOwner }.count < Constants.maxSharedSpaces
    }
    
    func startSubscription() async {
        Publishers.CombineLatest(workspaceStorage.allWorkspsacesPublisher, accountParticipantsStorage.participantsPublisher)
            .sink { [weak self] spaces, participants in
                self?.allParticipantSpaces = spaces.compactMap { space in
                    let participant = participants.first(where:  { $0.spaceId == space.targetSpaceId })
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
