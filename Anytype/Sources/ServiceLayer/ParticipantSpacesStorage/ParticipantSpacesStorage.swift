import Foundation
import Combine
import Services
import AnytypeCore

protocol ParticipantSpacesStorageProtocol: AnyObject, Sendable {
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

final class ParticipantSpacesStorage: ParticipantSpacesStorageProtocol {
    
    // MARK: - DI
    
    private let workspaceStorage: any WorkspacesStorageProtocol = Container.shared.workspaceStorage()
    private let accountParticipantsStorage: any AccountParticipantsStorageProtocol = Container.shared.accountParticipantsStorage()
    private let serverConfigurationStorage: any ServerConfigurationStorageProtocol = Container.shared.serverConfigurationStorage()
    private let subscriptionService: any SingleObjectSubscriptionServiceProtocol = Container.shared.singleObjectSubscriptionService()
    private let accountManager: any AccountManagerProtocol = Container.shared.accountManager()
    
    private let subscription = AtomicStorage<AnyCancellable?>(nil)
    private let subId = "ParticipantSpacesStorage-\(UUID().uuidString)"
    
    private let sharedSpacesLimit = AtomicStorage<Int?>(nil)
    private let allParticipantSpacesStorage = AtomicPublishedStorage<[ParticipantSpaceViewData]>([])

    // MARK: - Public
    
    var allParticipantSpaces: [ParticipantSpaceViewData] { allParticipantSpacesStorage.value }
    var allParticipantSpacesPublisher: AnyPublisher<[ParticipantSpaceViewData], Never> { allParticipantSpacesStorage.publisher }
    
    nonisolated init() {}
    
    var spaceSharingInfo: SpaceSharingInfo? {
        guard let sharedSpacesLimit = sharedSpacesLimit.value else { return nil }
        let sharedSpacesCount = allParticipantSpaces.filter { $0.spaceView.isActive && $0.spaceView.isShared && $0.isOwner }.count
        return SpaceSharingInfo(sharedSpacesLimit: sharedSpacesLimit, sharedSpacesCount: sharedSpacesCount)
    }
    
    func startSubscription() async {
        subscription.value = Publishers.CombineLatest(workspaceStorage.allWorkspsacesPublisher, accountParticipantsStorage.participantsPublisher)
            .sink { [weak self] spaces, participants in
                self?.updateData(spaces: spaces, participants: participants)
            }
        
        await subscriptionService.startSubscription(
            subId: subId,
            spaceId: accountManager.account.info.techSpaceId,
            objectId: accountManager.account.info.profileObjectID,
            additionalKeys: [.sharedSpacesLimit]
        ) { [weak self] details in
            self?.handleSubscription(details: details)
        }
    }
    
    func stopSubscription() async {
        subscription.value?.cancel()
        subscription.value = nil
        await subscriptionService.stopSubscription(subId: subId)
    }
    
    // MARK: - Private
    
    private func handleSubscription(details: ObjectDetails) {
        sharedSpacesLimit.value = details.sharedSpacesLimit
    }
    
    private func updateData(spaces: [SpaceView], participants: [Participant]) {
        allParticipantSpacesStorage.value = spaces.compactMap { space in
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
