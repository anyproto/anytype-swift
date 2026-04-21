import Foundation
import Services
import AnytypeCore

@MainActor
@Observable
final class MyFavoritesViewModel {

    // MARK: - DI

    @ObservationIgnored
    let personalWidgetsObject: any BaseDocumentProtocol
    @ObservationIgnored
    let channelWidgetsObject: any BaseDocumentProtocol
    @ObservationIgnored
    let onObjectSelected: (ObjectDetails) -> Void

    @ObservationIgnored
    private let spaceId: String

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

    @ObservationIgnored
    private var sourceBlocks: [SourceBlock] = []
    @ObservationIgnored
    private var chatPreviews: [ChatMessagePreview] = []
    @ObservationIgnored
    private var spaceView: SpaceView?

    // MARK: - Published state

    var rows: [MyFavoritesRowData] = []
    var pinnedToChannelObjectIds: Set<String> = []

    var canManageChannelPins: Bool {
        participantSpacesStorage
            .participantSpaceView(spaceId: spaceId)?
            .canManageChannelPins ?? false
    }

    init(
        spaceId: String,
        personalWidgetsObject: any BaseDocumentProtocol,
        channelWidgetsObject: any BaseDocumentProtocol,
        onObjectSelected: @escaping (ObjectDetails) -> Void
    ) {
        self.spaceId = spaceId
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
            let next: [SourceBlock] = widgets.compactMap { block in
                guard let info = personalWidgetsObject.widgetInfo(block: block),
                      case let .object(details) = info.source,
                      details.isNotDeletedAndSupportedForOpening else {
                    return nil
                }
                return SourceBlock(blockId: block.id, details: details)
            }
            guard sourceBlocks != next else { continue }
            sourceBlocks = next
            recomputeRows()
        }
    }

    private func startChannelPinsSubscription() async {
        for await _ in channelWidgetsObject.syncPublisher.values {
            var next: Set<String> = []
            for block in channelWidgetsObject.children where block.isWidget {
                guard let info = channelWidgetsObject.widgetInfo(block: block),
                      case let .object(details) = info.source else { continue }
                next.insert(details.id)
            }
            guard pinnedToChannelObjectIds != next else { continue }
            pinnedToChannelObjectIds = next
        }
    }

    private func startChatPreviewsSubscription() async {
        for await previews in await chatMessagesPreviewsStorage.previewsSequence {
            chatPreviews = previews
            recomputeRows()
        }
    }

    private func startSpaceViewSubscription() async {
        for await spaceView in spaceViewsStorage.spaceViewPublisher(spaceId: spaceId).values {
            self.spaceView = spaceView
            recomputeRows()
        }
    }

    // MARK: - Row recomputation

    private func recomputeRows() {
        let onObjectSelected = self.onObjectSelected
        let spaceView = self.spaceView
        let previewsByChatId = Dictionary(chatPreviews.map { ($0.chatId, $0) }, uniquingKeysWith: { first, _ in first })
        let newRows: [MyFavoritesRowData] = sourceBlocks.map { block in
            let details = block.details
            let chatPreview = previewsByChatId[details.id].flatMap {
                chatPreviewBuilder.build(chatPreview: $0, spaceView: spaceView)
            }
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
        rows.move(fromOffsets: IndexSet(integer: from.index), toOffset: to.index)
    }

    func dropFinish(from: DropDataElement<MyFavoritesRowData>, to: DropDataElement<MyFavoritesRowData>) {
        guard from.data.id != to.data.id else { return }
        AnytypeAnalytics.instance().logReorderWidget(source: .personalFavorites)
        let dashboardId = personalWidgetsObject.objectId
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

private struct SourceBlock: Equatable {
    let blockId: String
    let details: ObjectDetails
}
