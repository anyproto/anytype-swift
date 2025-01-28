import Foundation
import Services

@MainActor
protocol SimpleSetModuleOutput: AnyObject {
    func onObjectSelected(screenData: ScreenData)
}

@MainActor
final class SimpleSetViewModel: ObservableObject {
        
    @Published var title = ""
    @Published var objectsSubscriptionId: String? = nil
    @Published var sections = [ListSectionData<String?, WidgetObjectListRowModel>]()

    @Injected(\.documentService)
    private var documentService: any OpenedDocumentsProviderProtocol
    @Injected(\.simpleSetSubscriptionService)
    private var simpleSetSubscriptionService: any SimpleSetSubscriptionServiceProtocol
    
    private let objectId: String
    private let spaceId: String
    private weak var output: (any SimpleSetModuleOutput)?
    
    private lazy var setDocument: any SetDocumentProtocol = {
        documentService.setDocument(objectId: objectId, spaceId: spaceId)
    }()
    
    private var details = [ObjectDetails]()
    var isInitial = true
    
    init(objectId: String, spaceId: String, output: (any SimpleSetModuleOutput)?) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.output = output
    }
    
    func subscribeOnDetails() async {
        for await details in setDocument.detailsPublisher.values {
            title = details.pageCellTitle
            objectsSubscriptionId = details.id
        }
    }
    
    func startObjectsSubscription() async {
        guard setDocument.canStartSubscription() else { return }
        await simpleSetSubscriptionService.startSubscription(
            setDocument: setDocument,
            update: { [weak self] details, objectsToLoad in
                self?.details = details
                self?.updateInitialStateIfNeeded()
                self?.updateRows()
            })
    }
    
    func stopObjectsSubscription() {
        Task {
            await simpleSetSubscriptionService.stopSubscription()
        }
    }
    
    private func updateRows() {
        sections = [listSectionData(title: nil, details: details)]
    }
    
    private func listSectionData(title: String?, details: [ObjectDetails]) -> ListSectionData<String?, WidgetObjectListRowModel> {
        ListSectionData(
            id: title ?? UUID().uuidString,
            data: title,
            rows: details.map { details in
                WidgetObjectListRowModel(
                    details: details,
                    canArchive: false,
                    onTap: { [weak self] in
                        self?.output?.onObjectSelected(screenData: details.screenData())
                    }
                )
            }
        )
    }
    
    private func updateInitialStateIfNeeded() {
        guard isInitial else { return }
        isInitial = false
    }
}
