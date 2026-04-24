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
    let onObjectSelected: (ObjectDetails) -> Void

    @ObservationIgnored
    let spaceId: String

    @ObservationIgnored
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol

    // MARK: - Source state

    @ObservationIgnored
    private var sourceBlocks: [SourceBlock] = []

    // MARK: - Published state

    var rows: [MyFavoritesRowData] = []

    init(
        spaceId: String,
        personalWidgetsObject: any BaseDocumentProtocol,
        onObjectSelected: @escaping (ObjectDetails) -> Void
    ) {
        self.spaceId = spaceId
        self.personalWidgetsObject = personalWidgetsObject
        self.onObjectSelected = onObjectSelected
    }

    // MARK: - Subscriptions

    func startSubscriptions() async {
        await startPersonalWidgetsSubscription()
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

    // MARK: - Row recomputation

    private func recomputeRows() {
        let onObjectSelected = self.onObjectSelected
        let newRows: [MyFavoritesRowData] = sourceBlocks.map { block in
            let details = block.details
            return MyFavoritesRowData(
                id: block.blockId,
                objectId: details.id,
                title: details.pluralTitle,
                icon: details.objectIconImage,
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
