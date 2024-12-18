import SwiftUI
import Services


@MainActor
final class ObjectTypeObjectsListViewModel: ObservableObject {
    @Published var rows = [WidgetObjectListRowModel]()
    @Published var numberOfObjectsLeft = 0
    @Published var sort = AllContentSort(relation: .dateUpdated)
    
    var isEditorLayout: Bool { document.details?.recommendedLayoutValue?.isEditorLayout ?? false }
    
    @Published private var detailsOfSet: ObjectDetails?
    var setButtonText: String { detailsOfSet.isNotNil ? Loc.openSet : Loc.createSet }
    
    @Injected(\.objectsListSubscriptionService)
    private var listService: any ObjectsListSubscriptionServiceProtocol
    @Injected(\.setByTypeSubscriptionService)
    private var setService: any SetByTypeSubscriptionServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    
    private let document: any BaseDocumentProtocol
    
    private weak var output: (any ObjectTypeObjectsListViewModelOutput)?
    
    init(document: any BaseDocumentProtocol, output: (any ObjectTypeObjectsListViewModelOutput)?) {
        self.document = document
        self.output = output
    }
    
    func startListSubscription() async {
        await listService.startSubscription(objectTypeId: document.objectId, spaceId: document.spaceId, sort: sort) { details, numberOfObjectsLeft in
            self.rows = details.map { details in
                WidgetObjectListRowModel(details: details, canArchive: false) { [weak self] in
                    self?.output?.onOpenObjectTap(objectId: details.id)
                }
            }
            self.numberOfObjectsLeft = numberOfObjectsLeft
        }
    }
    
    func startSetSubscription() async {
        await setService.startSubscription(typeId: document.objectId, spaceId: document.spaceId) { [weak self] details in
            self?.detailsOfSet = details
        }
    }
    
    func stopSubscriptions() {
        Task {
            await listService.stopSubscription()
            await setService.stopSubscription()
        }
    }
    
    func onCreateNewObjectTap() {
        output?.onCreateNewObjectTap()
    }
    
    func onSetButtonTap() async throws {
        if let detailsOfSet {
            output?.onOpenSetTap(objectId: detailsOfSet.id)
        } else {
            try await createAndOpenNewSet()
        }
    }
    
    private func createAndOpenNewSet() async throws {
        let setName: String
        if let details = document.details {
            setName = Loc.setOf(details.objectName)
        } else {
            setName = Loc.newSet
        }
        
        let detailsOfSet = try await objectActionsService.createSet(
            name: setName,
            iconEmoji: document.details?.iconEmoji,
            setOfObjectType: document.objectId,
            spaceId: document.spaceId
        )
        output?.onOpenSetTap(objectId: detailsOfSet.id)
    }
}
