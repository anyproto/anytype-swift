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
    private var lastAppliedParticipantIds: Set<String>?

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
        lastAppliedParticipantIds = nil
        unreadBySpaceStream.send([:])
    }

    // MARK: - Private

    private func applyParticipants(_ ids: Set<String>) async {
        guard lastAppliedParticipantIds != ids else { return }
        lastAppliedParticipantIds = ids
        try? await storage.startOrUpdateSubscription(
            data: subscriptionBuilder.build()
        ) { [unreadBySpaceStream, ids] state in
            unreadBySpaceStream.send(
                ObjectsWithUnreadDiscussionsAggregator.aggregate(
                    items: state.items,
                    myParticipantIds: ids
                )
            )
        }
    }
}
