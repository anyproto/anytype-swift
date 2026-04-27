import Foundation
import Factory
import AsyncAlgorithms
import AsyncTools
@preconcurrency import Combine
import NotificationsCore
import Services
import UserNotifications

protocol AppIconBadgeServiceProtocol: AnyObject, Sendable {
    func startUpdating() async
    func stopUpdatingAndClearBadge() async
}

actor AppIconBadgeService: AppIconBadgeServiceProtocol {

    // LazyInjected to avoid creating ChatMessagesPreviewsStorage before auth
    // (when basicUserInfoStorage.usersId is empty, its subscription silently skips)
    @LazyInjected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol
    @Injected(\.chatDetailsStorage)
    private var chatDetailsStorage: any ChatDetailsStorageProtocol
    @Injected(\.badgeCountStorage)
    private var badgeCountStorage: any BadgeCountStorageProtocol
    @Injected(\.objectsWithUnreadDiscussionsSubscription)
    private var objectsWithUnreadDiscussionsSubscription: any ObjectsWithUnreadDiscussionsSubscriptionProtocol

    private var updateTask: Task<Void, Never>?

    func startUpdating() async {
        updateTask?.cancel()

        // The discussion subscription primes its sequence with `[:]` and the chat / space-view streams
        // also prime, so the first combineLatest tick fires immediately with current values.
        let baseTriple = combineLatest(
            await chatMessagesPreviewsStorage.previewsSequenceWithEmpty,
            spaceViewsStorage.allSpaceViewsPublisher.values,
            await chatDetailsStorage.allChatsSequence
        )
        let stream = combineLatest(
            baseTriple,
            await objectsWithUnreadDiscussionsSubscription.unreadBySpaceSequence
        ).throttle(milliseconds: 300)

        updateTask = Task {
            for await (triple, discussionsBySpace) in stream {
                guard !Task.isCancelled else { return }
                let (previews, spaceViews, chatDetails) = triple
                await self.updateBadge(
                    previews: previews,
                    spaceViews: spaceViews,
                    chatDetails: chatDetails,
                    discussionsBySpace: discussionsBySpace
                )
            }
        }
    }

    func stopUpdatingAndClearBadge() async {
        updateTask?.cancel()
        updateTask = nil
        badgeCountStorage.badgeCount = 0
        try? await UNUserNotificationCenter.current().setBadgeCount(0)
    }

    // MARK: - Private

    private func updateBadge(
        previews: [ChatMessagePreview],
        spaceViews: [SpaceView],
        chatDetails: [ObjectDetails],
        discussionsBySpace: [String: SpaceDiscussionsUnreadInfo]
    ) async {
        let total = BadgeTotalCalculator.compute(
            previews: previews,
            spaceViews: spaceViews,
            chatDetails: chatDetails,
            discussionsBySpace: discussionsBySpace
        )
        guard total != badgeCountStorage.badgeCount else { return }
        badgeCountStorage.badgeCount = total
        try? await UNUserNotificationCenter.current().setBadgeCount(total)
    }
}
