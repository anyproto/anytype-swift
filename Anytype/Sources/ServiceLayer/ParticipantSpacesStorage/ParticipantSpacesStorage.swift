import Foundation
import Combine
import Services


@MainActor
protocol ParticipantSpacesStorageProtocol: AnyObject {
    var allParticipantSpaces: [ParticipantSpaceViewData] { get }
    var allParticipantSpacesPublisher: AnyPublisher<[ParticipantSpaceViewData], Never> { get }
    var spaceSharingInfo: SpaceSharingInfo? { get }
    
    func startSubscription() async
    func stopSubscription() async
}

extension ParticipantSpacesStorageProtocol {
    
    var activeParticipantSpaces: [ParticipantSpaceViewData] {
        allParticipantSpaces.filter(\.spaceView.isActive)
    }
    
    var activeParticipantSpacesPublisher: AnyPublisher<[ParticipantSpaceViewData], Never> {
        allParticipantSpacesPublisher.map { $0.filter(\.spaceView.isActive) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var activeOrLoadingParticipantSpacesPublisher: AnyPublisher<[ParticipantSpaceViewData], Never> {
        allParticipantSpacesPublisher.map {
            $0.filter { $0.spaceView.isActive || $0.spaceView.isLoading }
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
    
    func participantSpaceView(spaceId: String) -> ParticipantSpaceViewData? {
        allParticipantSpaces.first { $0.spaceView.targetSpaceId == spaceId }
    }
    
    func participantSpaceViewPublisher(spaceId: String) -> AnyPublisher<ParticipantSpaceViewData, Never> {
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
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: any AccountParticipantsStorageProtocol
    @Injected(\.serverConfigurationStorage)
    private var serverConfigurationStorage: any ServerConfigurationStorageProtocol
    @Injected(\.singleObjectSubscriptionService)
    private var subscriptionService: any SingleObjectSubscriptionServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    
    private var subscriptions: [AnyCancellable] = []
    private let subId = "ParticipantSpacesStorage-\(UUID().uuidString)"
    
    private var sharedSpacesLimit: Int?
    
    // MARK: - State

    @Published private(set) var allParticipantSpaces: [ParticipantSpaceViewData] = []
    var allParticipantSpacesPublisher: AnyPublisher<[ParticipantSpaceViewData], Never> { $allParticipantSpaces.eraseToAnyPublisher() }
    
    nonisolated init() {}
    
    var spaceSharingInfo: SpaceSharingInfo? {
        guard let sharedSpacesLimit else { return nil }
        let sharedSpacesCount = allParticipantSpaces.filter { $0.spaceView.isActive && $0.spaceView.isShared && $0.isOwner }.count
        return SpaceSharingInfo(sharedSpacesLimit: sharedSpacesLimit, sharedSpacesCount: sharedSpacesCount)
    }
    
    func startSubscription() async {
        Publishers.CombineLatest(workspaceStorage.allWorkspsacesPublisher, accountParticipantsStorage.participantsPublisher)
            .sink { [weak self] spaces, participants in
                self?.updateData(spaces: spaces, participants: participants)
            }
            .store(in: &subscriptions)
        
        await subscriptionService.startSubscription(
            subId: subId,
            objectId: accountManager.account.info.profileObjectID
        ) { [weak self] details in
            self?.sharedSpacesLimit = details.sharedSpacesLimit
        }
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
            return ParticipantSpaceViewData(
                spaceView: space,
                participant: participant,
                permissions: permissions
            )
        }
    }
}
