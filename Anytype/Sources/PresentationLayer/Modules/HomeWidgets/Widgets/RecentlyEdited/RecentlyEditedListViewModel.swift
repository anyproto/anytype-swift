import Foundation
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
        onObjectSelected: @escaping (ObjectDetails) -> Void
    ) {
        self.spaceId = spaceId
        self.onObjectSelected = onObjectSelected
    }

    // MARK: - Subscriptions

    func startSubscriptions() async {
        await recentSubscriptionService.startSubscription(
            spaceId: spaceId,
            type: .recentEdit,
            objectLimit: Constants.limit,
            update: { [weak self] details in
                self?.rows = details.map { RecentlyEditedRowData(id: $0.id, details: $0) }
            }
        )
    }
}
