import Foundation
import SwiftUI
import Services
import AnytypeCore

@MainActor
@Observable
final class MyFavoritesListViewModel {

    // MARK: - DI

    @ObservationIgnored
    let personalWidgetsObject: any BaseDocumentProtocol
    @ObservationIgnored
    let channelWidgetsObject: any BaseDocumentProtocol
    @ObservationIgnored
    let onObjectSelected: (ObjectDetails) -> Void

    @ObservationIgnored
    let spaceId: String

    @ObservationIgnored
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol

    // MARK: - Source state

    @ObservationIgnored
    private var sourceIds: [String] = []

    // MARK: - Published state

    var rows: [MyFavoritesRowData] = []

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
        let seed = buildRows()
        self.sourceIds = seed.map(\.id)
        self.rows = seed
    }

    // MARK: - Subscriptions

    func startSubscriptions() async {
        await startPersonalWidgetsSubscription()
    }

    private func buildRows() -> [MyFavoritesRowData] {
        let widgets = personalWidgetsObject.children.filter(\.isWidget)
        return widgets.compactMap { block in
            guard let info = personalWidgetsObject.widgetInfo(block: block),
                  case let .object(details) = info.source,
                  details.isNotDeletedAndSupportedForOpening else {
                return nil
            }
            return MyFavoritesRowData(id: block.id, details: details)
        }
    }

    private func startPersonalWidgetsSubscription() async {
        for await _ in personalWidgetsObject.syncPublisher.values {
            // Dedup on STRUCTURAL changes only (block-id list), not on detail-only emissions.
            // - Compares against the persisted-order snapshot, not against `rows`, which `dropUpdate`
            //   mutates into the optimistic drag order — comparing against `rows` would snap the list
            //   back mid-drag on any unchanged-source emission.
            // - Detail-only updates (renames, icon changes) are handled by per-row VMs via
            //   `widgetTargetDetailsPublisher`, so the parent doesn't need to rebuild for those.
            let newRows = buildRows()
            let newIds = newRows.map(\.id)
            guard sourceIds != newIds else { continue }
            sourceIds = newIds
            rows = newRows
        }
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
