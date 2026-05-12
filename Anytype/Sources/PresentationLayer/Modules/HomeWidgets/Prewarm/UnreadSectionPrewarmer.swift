import Foundation
import Services
import AnytypeCore

@MainActor
protocol UnreadSectionPrewarmerProtocol: AnyObject, Sendable {
    func prewarm(spaceId: String) async -> PrefetchedUnreadSection?
}

@MainActor
final class UnreadSectionPrewarmer: UnreadSectionPrewarmerProtocol {

    @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    @Injected(\.chatDetailsStorage)
    private var chatDetailsStorage: any ChatDetailsStorageProtocol
    @Injected(\.objectsWithUnreadDiscussionsSubscription)
    private var unreadDiscussionsSubscription: any ObjectsWithUnreadDiscussionsSubscriptionProtocol
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol

    nonisolated init() {}

    /// In-memory snapshots — no timeout; cold-start aggregator returns `[:]` and the live subscription fills gaps.
    func prewarm(spaceId: String) async -> PrefetchedUnreadSection? {
        let spaceView = spaceViewsStorage.spaceView(spaceId: spaceId)
        let supportsMultiChats = !(spaceView?.isOneToOne ?? false)
        guard supportsMultiChats else { return nil }

        async let previews = chatMessagesPreviewsStorage.previews()
        async let chats = chatDetailsStorage.allChats()
        async let unreadBySpace = unreadDiscussionsSubscription.snapshot

        let (p, c, u) = await (previews, chats, unreadBySpace)
        guard let spaceView else { return PrefetchedUnreadSection(rows: [], supportsMultiChats: true) }

        let rows = UnreadSectionViewModel.mergeUnreadRows(
            previews: p,
            chatDetails: c,
            spaceView: spaceView,
            unreadBySpace: u,
            spaceId: spaceId
        )
        return PrefetchedUnreadSection(rows: rows, supportsMultiChats: true)
    }
}
