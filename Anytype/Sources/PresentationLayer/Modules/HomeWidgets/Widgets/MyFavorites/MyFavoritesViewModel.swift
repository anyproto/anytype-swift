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
    @ObservationIgnored
    weak var output: (any MyFavoritesModuleOutput)?

    @ObservationIgnored
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol

    // MARK: - Row

    struct Row: Identifiable, Equatable {
        /// Widget block id inside the personal widgets virtual document. Stable per-favorite,
        /// used both as the SwiftUI identity and as the block id handed to reorder / remove
        /// RPCs in Tasks 10 and 11.
        let id: String
        let details: ObjectDetails

        static func == (lhs: Row, rhs: Row) -> Bool {
            lhs.id == rhs.id && lhs.details == rhs.details
        }
    }

    // MARK: - State

    var rows: [Row] = []
    var isLoaded: Bool = false

    init(
        accountInfo: AccountInfo,
        personalWidgetsObject: any BaseDocumentProtocol,
        output: (any MyFavoritesModuleOutput)?
    ) {
        self.accountInfo = accountInfo
        self.personalWidgetsObject = personalWidgetsObject
        self.output = output
    }

    // MARK: - Subscriptions

    func startSubscriptions() async {
        for await _ in personalWidgetsObject.syncPublisher.values {
            isLoaded = true

            let widgets = personalWidgetsObject.children.filter(\.isWidget)
            let newRows: [Row] = widgets.compactMap { block in
                guard let info = personalWidgetsObject.widgetInfo(block: block),
                      case let .object(details) = info.source,
                      details.isNotDeletedAndSupportedForOpening else {
                    return nil
                }
                return Row(id: block.id, details: details)
            }

            guard rows != newRows else { continue }
            rows = newRows
        }
    }

    // MARK: - Actions

    func onTapRow(details: ObjectDetails) {
        output?.onObjectSelected(details: details)
    }

    // MARK: - Drag-and-drop

    func dropUpdate(from: DropDataElement<Row>, to: DropDataElement<Row>) {
        // Optimistic local reorder so the gesture feels immediate. The authoritative
        // tree arrives via `syncPublisher` once the move RPC completes.
        rows.move(fromOffsets: IndexSet(integer: from.index), toOffset: to.index)
    }

    func dropFinish(from: DropDataElement<Row>, to: DropDataElement<Row>) {
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
