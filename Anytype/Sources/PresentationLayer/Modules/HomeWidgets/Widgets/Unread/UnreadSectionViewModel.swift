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
    private let workspaceStorage: any SpaceViewsStorageProtocol = Container.shared.spaceViewsStorage()

    // MARK: - State

    var unreadItems: [UnreadSectionItem] = []
    var unreadSectionIsExpanded: Bool = false
    var supportsMultiChats: Bool = false

    var shouldShowUnreadSection: Bool { supportsMultiChats && unreadItems.isNotEmpty }
    var shouldHideChatBadges: Bool { shouldShowUnreadSection && unreadSectionIsExpanded }

    private static let expandedStorageId = "HomeUnreadSection"

    init(spaceId: String, output: (any CommonWidgetModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
        self.unreadSectionIsExpanded = expandedService.isExpanded(id: Self.expandedStorageId, defaultValue: true)
    }

    // MARK: - Subscriptions

    func startSubscriptions() async {
        async let unreadSub: () = startUnreadItemsTask()
        async let spaceViewSub: () = startSpaceViewTask()
        _ = await (unreadSub, spaceViewSub)
    }

    func onTapUnreadHeader() {
        withAnimation {
            unreadSectionIsExpanded.toggle()
        }
        expandedService.setState(id: Self.expandedStorageId, isExpanded: unreadSectionIsExpanded)
    }

    private func startSpaceViewTask() async {
        for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: spaceId).removeDuplicates().values {
            supportsMultiChats = !spaceView.isOneToOne
        }
    }

    private func startUnreadItemsTask() async {
        let spaceId = spaceId
        let spaceView = workspaceStorage.spaceView(spaceId: spaceId)
        guard !(spaceView?.isOneToOne ?? true) else { return }

        let previewsSequence = await chatMessagesPreviewsStorage.previewsSequenceWithEmpty
        let chatsSequence = await chatDetailsStorage.allChatsSequence
        let spaceViewSequence = workspaceStorage.spaceViewPublisher(spaceId: spaceId).removeDuplicates().values
        let unreadDiscussionsSequence = await unreadDiscussionsSubscription.unreadBySpaceSequence

        // combineLatest is max-arity 3 — nest two pairs.
        let chatTriple = combineLatest(previewsSequence, chatsSequence, spaceViewSequence)
        for await (triple, unreadBySpace) in combineLatest(chatTriple, unreadDiscussionsSequence) {
            let (previews, chatDetails, currentSpaceView) = triple

            let chatItems: [UnreadSectionItem] = previews.compactMap { preview in
                guard preview.spaceId == spaceId else { return nil }

                if FeatureFlags.muteAndHide {
                    let mode = currentSpaceView.effectiveNotificationMode(for: preview.chatId)
                    if mode == .nothing {
                        guard preview.mentionCounter > 0 || preview.hasUnreadReactions else { return nil }
                    }
                }

                guard preview.hasCounters else { return nil }
                guard let chatDetail = chatDetails.first(where: { $0.id == preview.chatId }), !chatDetail.isArchivedOrDeleted else {
                    return nil
                }
                return .chat(
                    UnreadChatWidgetData(id: preview.chatId, spaceId: spaceId, output: output),
                    lastMessageDate: preview.lastMessage?.createdAt
                )
            }

            let parentSource = FeatureFlags.discussionButton ? (unreadBySpace[spaceId]?.parents ?? []) : []
            let parentItems: [UnreadSectionItem] = parentSource.compactMap { parent in
                if FeatureFlags.muteAndHide && currentSpaceView.pushNotificationMode == .nothing {
                    guard parent.hasUnreadMention else { return nil }
                }
                // Aggregator admits any subscribed parent; drop fully-caught-up rows here so the section
                // never shows a name with no badge. Mirrors the chat path's `hasCounters` guard.
                guard parent.unreadMessageCount > 0 || parent.hasUnreadMention else { return nil }
                return .discussionParent(
                    UnreadDiscussionParentWidgetData(id: parent.id, spaceId: spaceId, output: output),
                    lastMessageDate: parent.lastMessageDate
                )
            }

            let merged = (chatItems + parentItems).sorted { $0.sortDate > $1.sortDate }
            guard unreadItems != merged else { continue }
            unreadItems = merged
        }
    }
}
