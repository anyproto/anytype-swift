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

    @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol
    @Injected(\.chatDetailsStorage)
    private var chatDetailsStorage: any ChatDetailsStorageProtocol
    @Injected(\.badgeCountStorage)
    private var badgeCountStorage: any BadgeCountStorageProtocol

    private var updateTask: Task<Void, Never>?

    func startUpdating() async {
        updateTask?.cancel()

        // Compute badge immediately from current values
        let currentPreviews = await chatMessagesPreviewsStorage.previews()
        let currentSpaceViews = spaceViewsStorage.allSpaceViews
        let currentChatDetails = await chatDetailsStorage.allChats()
        await updateBadge(previews: currentPreviews, spaceViews: currentSpaceViews, chatDetails: currentChatDetails)

        // Subscribe to ongoing updates
        let stream = combineLatest(
            await chatMessagesPreviewsStorage.previewsSequenceWithEmpty,
            spaceViewsStorage.allSpaceViewsPublisher.values,
            await chatDetailsStorage.allChatsSequence
        ).throttle(milliseconds: 300)

        updateTask = Task {
            for await (previews, spaceViews, chatDetails) in stream {
                guard !Task.isCancelled else { return }
                await self.updateBadge(previews: previews, spaceViews: spaceViews, chatDetails: chatDetails)
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
        chatDetails: [ObjectDetails]
    ) async {
        var total = 0

        for preview in previews {
            guard let chatDetail = chatDetails.first(where: { $0.id == preview.chatId }),
                  !chatDetail.isArchivedOrDeleted else {
                continue
            }

            guard let spaceView = spaceViews.first(where: { $0.targetSpaceId == preview.spaceId }),
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

        badgeCountStorage.badgeCount = total
        try? await UNUserNotificationCenter.current().setBadgeCount(total)
    }
}
