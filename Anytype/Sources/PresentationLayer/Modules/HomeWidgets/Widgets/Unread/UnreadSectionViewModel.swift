import Foundation
import SwiftUI
import Services
import AnytypeCore
import AsyncAlgorithms

@MainActor
@Observable
final class UnreadSectionViewModel {

    // MARK: - DI

    @ObservationIgnored
    let spaceId: String
    @ObservationIgnored
    weak var output: (any CommonWidgetModuleOutput)?

    @ObservationIgnored
    @Injected(\.expandedService)
    private var expandedService: any ExpandedServiceProtocol
    @ObservationIgnored
    @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    @ObservationIgnored
    @Injected(\.chatDetailsStorage)
    private var chatDetailsStorage: any ChatDetailsStorageProtocol
    @ObservationIgnored
    @Injected(\.objectsWithUnreadDiscussionsSubscription)
    private var unreadDiscussionsSubscription: any ObjectsWithUnreadDiscussionsSubscriptionProtocol
    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol

    // MARK: - State

    var unreadItems: [UnreadSectionRowData] = []
    var unreadSectionIsExpanded: Bool = false
    private var supportsMultiChats: Bool = false

    var shouldShowUnreadSection: Bool { supportsMultiChats && unreadItems.isNotEmpty }
    var shouldHideChatBadges: Bool { shouldShowUnreadSection && unreadSectionIsExpanded }

    init(spaceId: String, output: (any CommonWidgetModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
        self.unreadSectionIsExpanded = expandedService.isExpanded(section: .unread, defaultValue: true)
    }

    // MARK: - Subscriptions

    func startSubscriptions() async {
        async let unreadSub: () = startUnreadItemsTask()
        async let spaceViewSub: () = startSpaceViewTask()
        _ = await (unreadSub, spaceViewSub)
    }

    func onTapUnreadHeader() {
        unreadSectionIsExpanded = !unreadSectionIsExpanded
        expandedService.setState(section: .unread, isExpanded: unreadSectionIsExpanded)
    }

    func onRowTap(data: UnreadSectionRowData) {
        let source: AnalyticsWidgetSource = data.details.editorViewType == .chat
            ? .chat
            : .object(type: data.details.analyticsType)
        AnytypeAnalytics.instance().logClickWidgetTitle(source: source, createType: .manual)
        output?.onObjectSelected(screenData: data.details.screenData())
    }

    private func startSpaceViewTask() async {
        for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: spaceId).removeDuplicates().values {
            supportsMultiChats = !spaceView.isOneToOne
        }
    }

    private func startUnreadItemsTask() async {
        let spaceId = spaceId
        // No early-exit on isOneToOne — we'd capture the space type once and never observe
        // a 1:1 → multi-chat conversion. The combineLatest below re-fires on space-view
        // changes and the section's own visibility is gated by `supportsMultiChats`
        // (set in startSpaceViewTask), so 1:1 spaces simply pay the cost of a few
        // combineLatest emissions whose result the section ignores.
        let previewsSequence = await chatMessagesPreviewsStorage.previewsSequenceWithEmpty
        let chatsSequence = await chatDetailsStorage.allChatsSequence
        let spaceViewSequence = workspaceStorage.spaceViewPublisher(spaceId: spaceId).removeDuplicates().values
        let unreadDiscussionsSequence = await unreadDiscussionsSubscription.unreadBySpaceSequence

        // combineLatest is max-arity 3 — nest two pairs.
        let chatTriple = combineLatest(previewsSequence, chatsSequence, spaceViewSequence)
        for await (triple, unreadBySpace) in combineLatest(chatTriple, unreadDiscussionsSequence) {
            let (previews, chatDetails, currentSpaceView) = triple

            let chatItems: [UnreadSectionRowData] = previews.compactMap { preview in
                guard preview.spaceId == spaceId else { return nil }

                let mode = currentSpaceView.effectiveNotificationMode(for: preview.chatId)
                if FeatureFlags.muteAndHide && mode == .nothing {
                    guard preview.mentionCounter > 0 || preview.hasUnreadReactions else { return nil }
                }

                guard preview.hasCounters else { return nil }
                guard let chatDetail = chatDetails.first(where: { $0.id == preview.chatId }), !chatDetail.isArchivedOrDeleted else {
                    return nil
                }
                return UnreadSectionRowData(
                    id: chatDetail.id,
                    details: chatDetail,
                    notificationMode: mode,
                    unreadMessageCount: preview.unreadCounter,
                    unreadMentionCount: preview.mentionCounter,
                    hasUnreadReactions: preview.hasUnreadReactions,
                    isSubscribed: true,
                    lastMessageDate: preview.lastMessage?.createdAt
                )
            }

            let parentSource = FeatureFlags.discussionButton ? (unreadBySpace[spaceId]?.parents ?? []) : []
            let parentMode = currentSpaceView.pushNotificationMode
            let parentItems: [UnreadSectionRowData] = parentSource.compactMap { parent in
                if FeatureFlags.muteAndHide && parentMode == .nothing {
                    guard parent.hasUnreadMention else { return nil }
                }
                // Aggregator admits any subscribed parent; drop fully-caught-up rows here so the section
                // never shows a name with no badge. Mirrors the chat path's `hasCounters` guard.
                guard parent.unreadMessageCount > 0 || parent.hasUnreadMention else { return nil }
                return UnreadSectionRowData(
                    id: parent.id,
                    details: parent.details,
                    notificationMode: parentMode,
                    unreadMessageCount: parent.unreadMessageCount,
                    unreadMentionCount: parent.unreadMentionCount,
                    hasUnreadReactions: false,
                    isSubscribed: parent.isSubscribed,
                    lastMessageDate: parent.lastMessageDate
                )
            }

            let merged = (chatItems + parentItems)
                .sorted { ($0.lastMessageDate ?? .distantPast) > ($1.lastMessageDate ?? .distantPast) }
            guard unreadItems != merged else { continue }
            unreadItems = merged
        }
    }
}
