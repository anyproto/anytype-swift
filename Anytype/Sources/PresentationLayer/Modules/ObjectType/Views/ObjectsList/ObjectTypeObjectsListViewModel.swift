import SwiftUI
import Services


@MainActor
final class ObjectTypeObjectsListViewModel: ObservableObject {
    @Published var rows = [WidgetObjectListRowModel]()
    @Published var numberOfObjectsLeft = 0
    
    @Injected(\.objectsListSubscriptionService)
    private var service: any ObjectsListSubscriptionServiceProtocol
    
    private let objectTypeId: String
    private let spaceId: String
    
    init(objectTypeId: String, spaceId: String) {
        self.objectTypeId = objectTypeId
        self.spaceId = spaceId
    }
    
    func startSubscription() async {
        await service.startSubscription(objectTypeId: objectTypeId, spaceId: spaceId) { details, numberOfObjectsLeft in
            self.rows = details.map {
                WidgetObjectListRowModel(details: $0, canArchive: false) {
                    // TBD;
                }
            }
            self.numberOfObjectsLeft = numberOfObjectsLeft
        }
    }
    
    func stopStopSubscription() {
        Task {
            await service.stopSubscription()
        }
    }
}
