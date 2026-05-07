import Foundation
import SwiftUI
import Services
import AnytypeCore

@MainActor
@Observable
final class RecentlyEditedListViewModel {

    // MARK: - DI

    @ObservationIgnored
    let spaceId: String
    @ObservationIgnored
    let onObjectSelected: (ObjectDetails) -> Void
    @ObservationIgnored
    private let onRowsCountChange: ((Int) -> Void)?

    @ObservationIgnored
    @Injected(\.recentSubscriptionService)
    private var recentSubscriptionService: any RecentSubscriptionServiceProtocol

    private enum Constants {
        // Matches the desktop client's recentEdit subscription limit.
        static let limit = 10
    }

    // MARK: - Published state

    var rows: [RecentlyEditedRowData] = []

    init(
        spaceId: String,
        onObjectSelected: @escaping (ObjectDetails) -> Void,
        onRowsCountChange: ((Int) -> Void)? = nil
    ) {
        self.spaceId = spaceId
        self.onObjectSelected = onObjectSelected
        self.onRowsCountChange = onRowsCountChange
    }

    // MARK: - Subscriptions

    func startSubscriptions() async {
        await recentSubscriptionService.startSubscription(
            spaceId: spaceId,
            type: .recentEdit,
            objectLimit: Constants.limit,
            update: { [weak self] details in
                guard let self else { return }
                let newRows = details.map { RecentlyEditedRowData(id: $0.id, details: $0) }
                let countChanged = self.rows.count != newRows.count
                withAnimation(.default) {
                    if countChanged { self.onRowsCountChange?(newRows.count) }
                    self.rows = newRows
                }
            }
        )
    }
}
