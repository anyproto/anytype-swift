import Foundation
import Combine
import Services


@MainActor
protocol ParticipantSpacesStorageProtocol: AnyObject {
    var allParticipantSpaces: [ParticipantSpaceView] { get }
    var allParticipantSpacesPublisher: AnyPublisher<[ParticipantSpaceView], Never> { get }
    var spaceSharingInfo: SpaceSharingInfo? { get }
    
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
    
    func participantSpaceView(spaceId: String) -> ParticipantSpaceView? {
        allParticipantSpaces.first { $0.spaceView.targetSpaceId == spaceId }
    }
    
    func participantSpaceViewPublisher(spaceId: String) -> AnyPublisher<ParticipantSpaceView, Never> {
        allParticipantSpacesPublisher
            .compactMap { $0.first { $0.spaceView.targetSpaceId == spaceId } }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

@MainActor
final class ParticipantSpacesStorage: ParticipantSpacesStorageProtocol {
    
    // MARK: - DI
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: AccountParticipantsStorageProtocol
    @Injected(\.serverConfigurationStorage)
    private var serverConfigurationStorage: ServerConfigurationStorageProtocol
    
    private var subscriptions: [AnyCancellable] = []
    
    // MARK: - State
    
    @Published private(set) var allParticipantSpaces: [ParticipantSpaceView] = []
    var allParticipantSpacesPublisher: AnyPublisher<[ParticipantSpaceView], Never> { $allParticipantSpaces.eraseToAnyPublisher() }
    
    nonisolated init() {}
    
    var spaceSharingInfo: SpaceSharingInfo? {
        guard let sharedSpacesLimit = workspaceStorage.allWorkspaces.first(where: { $0.spaceAccessType == .personal })?.sharedSpacesLimit else { return nil }
        let sharedSpacesCount = allParticipantSpaces.filter { $0.spaceView.isActive && $0.spaceView.isShared && $0.isOwner }.count
        return SpaceSharingInfo(sharedSpacesLimit: sharedSpacesLimit, sharedSpacesCount: sharedSpacesCount)
    }
    
    func startSubscription() async {
        Publishers.CombineLatest(workspaceStorage.allWorkspsacesPublisher, accountParticipantsStorage.participantsPublisher)
            .sink { [weak self] spaces, participants in
                self?.updateData(spaces: spaces, participants: participants)
            }
            .store(in: &subscriptions)
    }
    
    func stopSubscription() async {
        subscriptions.removeAll()
    }
    
    // MARK: - Private
    
    private func updateData(spaces: [SpaceView], participants: [Participant]) {
        allParticipantSpaces = spaces.compactMap { space in
            let participant = participants.first(where:  { $0.spaceId == space.targetSpaceId })
            let permissions = SpacePermissions(
                spaceView: space,
                participant: participant,
                isLocalMode: serverConfigurationStorage.currentConfiguration().middlewareNetworkMode == .localOnly
            )
            return ParticipantSpaceView(
                spaceView: space,
                participant: participant,
                permissions: permissions
            )
        }
    }
}
