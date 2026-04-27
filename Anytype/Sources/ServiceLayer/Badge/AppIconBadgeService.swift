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
        let spaceViewById = Dictionary(spaceViews.map { ($0.targetSpaceId, $0) }, uniquingKeysWith: { _, last in last })
        var total = 0

        for preview in previews {
            guard let chatDetail = chatDetails.first(where: { $0.id == preview.chatId }),
                  !chatDetail.isArchivedOrDeleted else {
                continue
            }

            guard let spaceView = spaceViewById[preview.spaceId],
                  spaceView.isActive else {
                continue
            }

            let mode = spaceView.effectiveNotificationMode(for: preview.chatId)

            switch mode {
            case .all:
                total += preview.unreadCounter
            case .mentions:
                if spaceView.uxType.supportsMentions {
                    total += preview.mentionCounter
                }
            case .nothing, .UNRECOGNIZED:
                break
            }
        }

        for (spaceId, info) in discussionsBySpace {
            guard let spaceView = spaceViewById[spaceId], spaceView.isActive else { continue }

            switch spaceView.pushNotificationMode {
            case .all:
                // Subscribed-parent messages already include their mentions; add unsubscribed-parent
                // mentions on top so a mention in an object I don't watch still bumps the badge.
                total += info.unreadMessageCount + info.mentions.unsubscribedCount
            case .mentions:
                if spaceView.uxType.supportsMentions {
                    total += info.mentions.totalCount
                }
            case .nothing, .UNRECOGNIZED:
                break
            }
        }

        guard total != badgeCountStorage.badgeCount else { return }
        badgeCountStorage.badgeCount = total
        try? await UNUserNotificationCenter.current().setBadgeCount(total)
    }
}
