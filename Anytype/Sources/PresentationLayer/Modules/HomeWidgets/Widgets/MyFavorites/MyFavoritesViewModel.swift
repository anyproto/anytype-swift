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

    // MARK: - Drag-and-drop (Task 11)

    func dropUpdate(from: DropDataElement<Row>, to: DropDataElement<Row>) {
        // Optimistic local reorder — real implementation lands in Task 11.
        // Stubbed today so Task 5 can compile standalone; wiring into the view happens later.
    }

    func dropFinish(from: DropDataElement<Row>, to: DropDataElement<Row>) {
        // Async move via `ObjectActionsService.move(dashboadId: accountInfo.personalWidgetsId, ...)`
        // — real implementation lands in Task 11.
    }
}
