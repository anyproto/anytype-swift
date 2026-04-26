import Foundation
import Services
import AsyncTools

protocol ObjectsWithUnreadDiscussionsSubscriptionProtocol: AnyObject, Sendable {
    func startSubscription() async
    func stopSubscription() async
}

actor ObjectsWithUnreadDiscussionsSubscription: ObjectsWithUnreadDiscussionsSubscriptionProtocol {

    private let subscriptionBuilder: any ObjectsWithUnreadDiscussionsSubscriptionBuilderProtocol = ObjectsWithUnreadDiscussionsSubscriptionBuilder()
    private let subscriptionStorageProvider: any SubscriptionStorageProviderProtocol = Container.shared.subscriptionStorageProvider()
    private let participantsStorage: any ParticipantsStorageProtocol = Container.shared.participantsStorage()
    private let storage: any SubscriptionStorageProtocol

    private var participantsTask: Task<Void, Never>?
    private var lastAppliedParticipantIds: Set<String>?

    init() {
        self.storage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionBuilder.subscriptionId)
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
    }

    // MARK: - Private

    private func applyParticipants(_ ids: Set<String>) async {
        guard lastAppliedParticipantIds != ids else { return }
        lastAppliedParticipantIds = ids
        try? await storage.startOrUpdateSubscription(
            data: subscriptionBuilder.build(myParticipantIds: Array(ids))
        ) { state in
            Self.logMatched(state)
        }
    }

    private static func logMatched(_ state: SubscriptionStorageState) {
        let parentLayouts: Set<DetailsLayout> = Set(DetailsLayout.editorLayouts + DetailsLayout.listLayouts)
        let subscribedDiscussionIds = Set(
            state.items
                .filter { $0.resolvedLayoutValue == .discussion }
                .map(\.id)
        )
        let names = state.items
            .filter { parentLayouts.contains($0.resolvedLayoutValue) }
            .compactMap { parent -> String? in
                let hasMention = (parent.unreadMentionCount ?? 0) > 0
                let isSubscribed = subscribedDiscussionIds.contains(parent.discussionId)
                guard hasMention || isSubscribed else { return nil }
                return parent.name
            }
        debugPrint("[unread] matched=\(names)")
    }
}

