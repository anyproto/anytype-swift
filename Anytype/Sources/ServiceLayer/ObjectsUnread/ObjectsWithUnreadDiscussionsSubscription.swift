import Foundation
import Services
import AsyncTools

protocol ObjectsWithUnreadDiscussionsSubscriptionProtocol: AnyObject, Sendable {
    var unreadBySpaceSequence: AnyAsyncSequence<[String: SpaceDiscussionsUnreadInfo]> { get async }
    func startSubscription() async
    func stopSubscription() async
}

actor ObjectsWithUnreadDiscussionsSubscription: ObjectsWithUnreadDiscussionsSubscriptionProtocol {

    private let subscriptionBuilder: any ObjectsWithUnreadDiscussionsSubscriptionBuilderProtocol = ObjectsWithUnreadDiscussionsSubscriptionBuilder()
    private let subscriptionStorageProvider: any SubscriptionStorageProviderProtocol = Container.shared.subscriptionStorageProvider()
    private let participantsStorage: any ParticipantsStorageProtocol = Container.shared.participantsStorage()
    private let storage: any SubscriptionStorageProtocol

    private let unreadBySpaceStream = AsyncToManyStream<[String: SpaceDiscussionsUnreadInfo]>()

    private var participantsTask: Task<Void, Never>?
    private var currentParticipantIds: Set<String> = []
    private var lastObservedItems: [ObjectDetails] = []
    private var subscriptionStarted = false

    init() {
        self.storage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionBuilder.subscriptionId)
    }

    var unreadBySpaceSequence: AnyAsyncSequence<[String: SpaceDiscussionsUnreadInfo]> {
        unreadBySpaceStream.subscribe([:]).eraseToAnyAsyncSequence()
    }

    func startSubscription() async {
        participantsTask = Task { [weak self, participantsStorage] in
            for await participants in participantsStorage.participantsSequence {
                await self?.applyParticipants(Set(participants.map(\.id)))
            }
        }
    }

    func stopSubscription() async {
        participantsTask?.cancel()
        participantsTask = nil
        try? await storage.stopSubscription()
        currentParticipantIds = []
        lastObservedItems = []
        subscriptionStarted = false
        unreadBySpaceStream.send([:])
    }

    // MARK: - Private

    private func applyParticipants(_ ids: Set<String>) async {
        guard currentParticipantIds != ids else { return }
        currentParticipantIds = ids

        if subscriptionStarted {
            emitAggregate()
        } else {
            subscriptionStarted = true
            try? await storage.startOrUpdateSubscription(
                data: subscriptionBuilder.build()
            ) { [weak self] state in
                await self?.handleState(state)
            }
        }
    }

    private func handleState(_ state: SubscriptionStorageState) {
        lastObservedItems = state.items
        emitAggregate()
    }

    private func emitAggregate() {
        unreadBySpaceStream.send(
            ObjectsWithUnreadDiscussionsAggregator.aggregate(
                items: lastObservedItems,
                myParticipantIds: currentParticipantIds
            )
        )
    }
}
