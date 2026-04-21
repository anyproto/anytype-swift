import Foundation
import Services
import AnytypeCore

@MainActor
@Observable
final class MyFavoritesViewModel {

    // MARK: - DI

    @ObservationIgnored
    let accountInfo: AccountInfo
    @ObservationIgnored
    let personalWidgetsObject: any BaseDocumentProtocol
    /// Shared channel widgets document — used to compute the per-row
    /// `isPinnedToChannel` flag shown in the long-press menu.
    @ObservationIgnored
    let channelWidgetsObject: any BaseDocumentProtocol
    /// Row-tap routing. Plain closure (not a module-output protocol) because
    /// `HomeWidgetsView` already has a `CommonWidgetModuleOutput` it can forward
    /// to — adding another protocol indirection just to hand back the same
    /// `ScreenData` would be noise. See IOS-5864 Task 5.
    @ObservationIgnored
    let onObjectSelected: (ObjectDetails) -> Void

    @ObservationIgnored
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @ObservationIgnored
    @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored
    @Injected(\.widgetChatPreviewBuilder)
    private var chatPreviewBuilder: any WidgetChatPreviewBuilderProtocol

    // MARK: - Source state

    /// Raw per-favorite (block id + details) tuples sourced from the personal
    /// widgets document. Kept separate from the published `rows` so we can
    /// recompute the row array whenever chat previews / space view update
    /// without re-reading the document tree.
    @ObservationIgnored
    private var sourceBlocks: [(blockId: String, details: ObjectDetails)] = []
    @ObservationIgnored
    private var chatPreviews: [ChatMessagePreview] = []
    @ObservationIgnored
    private var spaceView: SpaceView?

    // MARK: - Published state

    var rows: [MyFavoritesRowData] = []
    /// Per-object `isPinnedToChannel` flags, keyed by `ObjectDetails.id`.
    /// Computed reactively from `channelWidgetsObject.syncPublisher` so each row can
    /// render a plain `Bool` without its own subscription (single source of truth).
    var pinnedToChannelByObjectId: [String: Bool] = [:]

    /// Owner-only gate for the row's `.pinToChannel` menu item. Read on demand from
    /// the participant-space storage snapshot — ownership transfer is rare enough
    /// that a live subscription isn't warranted. Mirrors `WidgetContainerViewModel`.
    var canManageChannelPins: Bool {
        participantSpacesStorage
            .participantSpaceView(spaceId: accountInfo.accountSpaceId)?
            .canManageChannelPins ?? false
    }

    init(
        accountInfo: AccountInfo,
        personalWidgetsObject: any BaseDocumentProtocol,
        channelWidgetsObject: any BaseDocumentProtocol,
        onObjectSelected: @escaping (ObjectDetails) -> Void
    ) {
        self.accountInfo = accountInfo
        self.personalWidgetsObject = personalWidgetsObject
        self.channelWidgetsObject = channelWidgetsObject
        self.onObjectSelected = onObjectSelected
    }

    // MARK: - Subscriptions

    func startSubscriptions() async {
        async let personalSub: () = startPersonalWidgetsSubscription()
        async let channelSub: () = startChannelPinsSubscription()
        async let chatPreviewsSub: () = startChatPreviewsSubscription()
        async let spaceViewSub: () = startSpaceViewSubscription()
        _ = await (personalSub, channelSub, chatPreviewsSub, spaceViewSub)
    }

    private func startPersonalWidgetsSubscription() async {
        for await _ in personalWidgetsObject.syncPublisher.values {
            let widgets = personalWidgetsObject.children.filter(\.isWidget)
            sourceBlocks = widgets.compactMap { block in
                guard let info = personalWidgetsObject.widgetInfo(block: block),
                      case let .object(details) = info.source,
                      details.isNotDeletedAndSupportedForOpening else {
                    return nil
                }
                return (blockId: block.id, details: details)
            }
            recomputeRows()
        }
    }

    /// Rebuilds `pinnedToChannelByObjectId` on every channel widgets document
    /// emission. Single subscription instead of one per row.
    private func startChannelPinsSubscription() async {
        for await _ in channelWidgetsObject.syncPublisher.values {
            var next: [String: Bool] = [:]
            let widgets = channelWidgetsObject.children.filter(\.isWidget)
            for block in widgets {
                guard let info = channelWidgetsObject.widgetInfo(block: block),
                      case let .object(details) = info.source else { continue }
                next[details.id] = true
            }
            guard pinnedToChannelByObjectId != next else { continue }
            pinnedToChannelByObjectId = next
        }
    }

    private func startChatPreviewsSubscription() async {
        for await previews in await chatMessagesPreviewsStorage.previewsSequence {
            chatPreviews = previews
            recomputeRows()
        }
    }

    private func startSpaceViewSubscription() async {
        for await spaceView in spaceViewsStorage.spaceViewPublisher(spaceId: accountInfo.accountSpaceId).values {
            self.spaceView = spaceView
            recomputeRows()
        }
    }

    // MARK: - Row recomputation

    /// Single projection point from raw sources to published `rows`. Called from
    /// every subscription so a chat-preview-only change (e.g. unread counter tick)
    /// still propagates without touching the personal widgets document.
    private func recomputeRows() {
        let onObjectSelected = self.onObjectSelected
        let spaceView = self.spaceView
        let newRows: [MyFavoritesRowData] = sourceBlocks.map { block in
            let chatPreview = chatPreviewBuilder.build(
                chatPreviews: chatPreviews,
                objectId: block.details.id,
                spaceView: spaceView
            )
            let details = block.details
            return MyFavoritesRowData(
                id: block.blockId,
                objectId: details.id,
                title: details.pluralTitle,
                icon: details.objectIconImage,
                chatPreview: chatPreview,
                onTap: { onObjectSelected(details) }
            )
        }
        guard rows != newRows else { return }
        rows = newRows
    }

    // MARK: - Drag-and-drop

    func dropUpdate(from: DropDataElement<MyFavoritesRowData>, to: DropDataElement<MyFavoritesRowData>) {
        guard from.data.id != to.data.id else { return }
        // Optimistic local reorder so the gesture feels immediate. The authoritative
        // tree arrives via `syncPublisher` once the move RPC completes.
        rows.move(fromOffsets: IndexSet(integer: from.index), toOffset: to.index)
    }

    func dropFinish(from: DropDataElement<MyFavoritesRowData>, to: DropDataElement<MyFavoritesRowData>) {
        guard from.data.id != to.data.id else { return }
        AnytypeAnalytics.instance().logReorderWidget(source: .personalFavorites)
        let dashboardId = accountInfo.personalWidgetsId
        let blockId = from.data.id
        let dropPositionblockId = to.data.id
        let isMovingDown = to.index > from.index
        Task { [objectActionsService] in
            try? await objectActionsService.move(
                dashboadId: dashboardId,
                blockId: blockId,
                dropPositionblockId: dropPositionblockId,
                position: isMovingDown ? .bottom : .top
            )
        }
    }
}
