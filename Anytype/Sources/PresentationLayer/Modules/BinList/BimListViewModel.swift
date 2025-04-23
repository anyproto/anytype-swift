import Combine
import Services

@MainActor
final class BinListViewModel: ObservableObject {
    
    private let spaceId: String
    @Injected(\.binSubscriptionService)
    private var binSubscriptionService: any BinSubscriptionServiceProtocol
    private var details: [ObjectDetails] = []
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func startSubscriptions() async {
        for await details in await binSubscriptionService.startSubscription(spaceId: spaceId, objectLimit: nil) {
            self.details = details
        }
    }
    
    func onSearch(text: String) {
        // TODO: implement
    }
}
