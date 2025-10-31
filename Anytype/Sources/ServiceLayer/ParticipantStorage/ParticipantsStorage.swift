import Foundation
import Services
import Combine
import AnytypeCore
import AsyncTools
import AsyncAlgorithms

protocol ParticipantsStorageProtocol: AnyObject, Sendable {
    var participants: [Participant] { get }
    var participantsSequence: AnyAsyncSequence<[Participant]> { get }
    func startSubscription() async
    func stopSubscription() async
}

extension ParticipantsStorageProtocol {
    func participantSequence(spaceId: String) -> AnyAsyncSequence<Participant> {
        participantsSequence.compactMap { $0.first { $0.spaceId == spaceId } }.removeDuplicates().eraseToAnyAsyncSequence()
    }

    func permissionSequence(spaceId: String) -> AnyAsyncSequence<ParticipantPermissions> {
        participantSequence(spaceId: spaceId).map(\.permission).removeDuplicates().eraseToAnyAsyncSequence()
    }

    func canEditSequence(spaceId: String) -> AnyAsyncSequence<Bool> {
        participantSequence(spaceId: spaceId).map(\.permission.canEdit).removeDuplicates().eraseToAnyAsyncSequence()
    }
}

actor ParticipantsStorage: ParticipantsStorageProtocol, Sendable {

    private let subscriptionId = "SubscriptionId.Participant-\(UUID().uuidString)"

    // MARK: - DI
    
    private let stream = AsyncToManyStream<[Participant]>()
    private var subscription: Task<Void, Never>?
    
    @LazyInjected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    
    private let subscriptionBuilder = AcountParticipantSubscriptionBuilder()
    
    // MARK: - State

    nonisolated var participants: [Participant] { stream.value ?? [] }
    nonisolated var participantsSequence: AnyAsyncSequence<[Participant]> { stream.eraseToAnyAsyncSequence() }

    func startSubscription() async {
        guard subscription.isNil else {
            anytypeAssertionFailure("Try to start ParticipantsStorage multiple times")
            return
        }
        
        let data = subscriptionBuilder.build(accountId: accountManager.account.id, subId: subscriptionId)
        try? await subscriptionStorage.startOrUpdateSubscription(data: data)
        
        subscription = Task { [weak self, subscriptionStorage] in
            for await state in subscriptionStorage.statePublisher.values {
                let participants = state.items.compactMap { try? Participant(details: $0) }
                self?.stream.send(participants)
            }
        }
    }

    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
        subscription?.cancel()
        subscription = nil
        stream.clearLastValue()
    }
}
