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
    
    private weak var output: (any ObjectTypeObjectsListViewModelOutput)?
    
    init(objectTypeId: String, spaceId: String, output: (any ObjectTypeObjectsListViewModelOutput)?) {
        self.objectTypeId = objectTypeId
        self.spaceId = spaceId
        self.output = output
    }
    
    func startSubscription() async {
        await service.startSubscription(objectTypeId: objectTypeId, spaceId: spaceId) { details, numberOfObjectsLeft in
            self.rows = details.map { details in
                WidgetObjectListRowModel(details: details, canArchive: false) { [weak self] in
                    self?.output?.onOpenObjectTap(objectId: details.id)
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
    
    func onCreateNewObjectTap() {
        output?.onCreateNewObjectTap()
    }
}
