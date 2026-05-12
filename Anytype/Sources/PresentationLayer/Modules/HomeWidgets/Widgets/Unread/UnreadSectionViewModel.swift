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
    // Pessimistic until the aggregator's first tick — see `shouldHideChatBadges`.
    private var didLoadInitial: Bool = false

    var shouldShowUnreadSection: Bool { supportsMultiChats && unreadItems.isNotEmpty }
    var shouldHideChatBadges: Bool {
        guard didLoadInitial else { return true }
        return shouldShowUnreadSection && unreadSectionIsExpanded
    }

    init(spaceId: String, prefetched: PrefetchedUnreadSection?, output: (any CommonWidgetModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
        self.unreadSectionIsExpanded = expandedService.isExpanded(section: .unread, defaultValue: true)

        if let prefetched {
            self.unreadItems = prefetched.rows
            self.supportsMultiChats = prefetched.supportsMultiChats
            // Release `shouldHideChatBadges` from its pessimistic `true` default.
            self.didLoadInitial = true
        } else {
            // Default to multi-chat when spaceView isn't loaded yet — the section is also gated
            // by `unreadItems.isNotEmpty`, so multi-chat-but-empty stays invisible.
            self.supportsMultiChats = !(workspaceStorage.spaceView(spaceId: spaceId)?.isOneToOne ?? false)
        }
    }

    // MARK: - Subscriptions

    func startSubscriptions() async {
        await startUnreadItemsTask()
    }

    func onTapUnreadHeader() {
        withAnimation(.snappy(duration: 0.28, extraBounce: 0.05)) {
            unreadSectionIsExpanded.toggle()
        }
        expandedService.setState(section: .unread, isExpanded: unreadSectionIsExpanded)
    }

    func onRowTap(data: UnreadSectionRowData) {
        let source: AnalyticsWidgetSource = data.details.editorViewType == .chat
            ? .chat
            : .object(type: data.details.analyticsType)
        AnytypeAnalytics.instance().logClickWidgetTitle(source: source, createType: .manual)
        output?.onObjectSelected(screenData: data.details.screenData())
    }

    private func startUnreadItemsTask() async {
        let spaceId = spaceId
        // No early-exit on isOneToOne — we'd capture the space type once and never observe
        // a 1:1 → multi-chat conversion. The combineLatest below re-fires on space-view
        // changes and the section's own visibility is gated by `supportsMultiChats`
        // (re-derived from each tick's `currentSpaceView`), so 1:1 spaces simply pay the
        // cost of a few combineLatest emissions whose result the section ignores.
        let previewsSequence = await chatMessagesPreviewsStorage.previewsSequenceWithEmpty
        let chatsSequence = await chatDetailsStorage.allChatsSequence
        let spaceViewSequence = workspaceStorage.spaceViewPublisher(spaceId: spaceId).removeDuplicates().values
        let unreadDiscussionsSequence = await unreadDiscussionsSubscription.unreadBySpaceSequence

        // combineLatest is max-arity 3 — nest two pairs.
        let chatTriple = combineLatest(previewsSequence, chatsSequence, spaceViewSequence)
        for await (triple, unreadBySpace) in combineLatest(chatTriple, unreadDiscussionsSequence) {
            let (previews, chatDetails, currentSpaceView) = triple

            // Flip even when the dedupe `guard` below skips the row diff — we now know the real state.
            if !didLoadInitial { didLoadInitial = true }

            let nextSupportsMultiChats = !currentSpaceView.isOneToOne
            if supportsMultiChats != nextSupportsMultiChats { supportsMultiChats = nextSupportsMultiChats }

            let merged = Self.mergeUnreadRows(
                previews: previews,
                chatDetails: chatDetails,
                spaceView: currentSpaceView,
                unreadBySpace: unreadBySpace,
                spaceId: spaceId
            )
            guard unreadItems != merged else { continue }
            unreadItems = merged
        }
    }

    static func mergeUnreadRows(
        previews: [ChatMessagePreview],
        chatDetails: [ObjectDetails],
        spaceView: SpaceView,
        unreadBySpace: [String: SpaceDiscussionsUnreadInfo],
        spaceId: String
    ) -> [UnreadSectionRowData] {
        let chatItems: [UnreadSectionRowData] = previews.compactMap { preview in
            guard preview.spaceId == spaceId else { return nil }

            let mode = spaceView.effectiveNotificationMode(for: preview.chatId)
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
        let parentMode = spaceView.pushNotificationMode
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

        return (chatItems + parentItems)
            .sorted { ($0.lastMessageDate ?? .distantPast) > ($1.lastMessageDate ?? .distantPast) }
    }
}
