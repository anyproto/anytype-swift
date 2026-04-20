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

    // MARK: - State

    var rows: [MyFavoritesRowData] = []
    /// Per-object `isPinnedToChannel` flags, keyed by `ObjectDetails.id`.
    /// Computed reactively from `channelWidgetsObject.syncPublisher` so each row can
    /// render a plain `Bool` without its own subscription (single source of truth).
    var pinnedToChannelByObjectId: [String: Bool] = [:]

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
        _ = await (personalSub, channelSub)
    }

    private func startPersonalWidgetsSubscription() async {
        for await _ in personalWidgetsObject.syncPublisher.values {
            let widgets = personalWidgetsObject.children.filter(\.isWidget)
            let newRows: [MyFavoritesRowData] = widgets.compactMap { block in
                guard let info = personalWidgetsObject.widgetInfo(block: block),
                      case let .object(details) = info.source,
                      details.isNotDeletedAndSupportedForOpening else {
                    return nil
                }
                // Bind routing at row-build time so the view never sees
                // `ObjectDetails` — matches the `ListWidgetRowModel` pattern
                // used by channel-pin rows.
                let onObjectSelected = self.onObjectSelected
                return MyFavoritesRowData(
                    id: block.id,
                    objectId: details.id,
                    title: details.pluralTitle,
                    icon: details.objectIconImage,
                    onTap: { onObjectSelected(details) }
                )
            }

            guard rows != newRows else { continue }
            rows = newRows
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
