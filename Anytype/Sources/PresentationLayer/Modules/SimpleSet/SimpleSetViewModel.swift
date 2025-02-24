import Foundation
import Services
import UIKit

@MainActor
protocol SimpleSetModuleOutput: AnyObject {
    func onObjectSelected(screenData: ScreenData)
}

@MainActor
final class SimpleSetViewModel: ObservableObject {
        
    @Published var title = ""
    @Published var state: SimpleSetState?
    @Published var data = SimpleSetLayout.list([])
    @Published private var participantCanEdit = false

    @Injected(\.openedDocumentProvider)
    private var documentService: any OpenedDocumentsProviderProtocol
    @Injected(\.simpleSetSubscriptionService)
    private var simpleSetSubscriptionService: any SimpleSetSubscriptionServiceProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantStorage: any AccountParticipantsStorageProtocol
    @Injected(\.objectActionsService)
    private var objectActionService: any ObjectActionsServiceProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    
    private let objectId: String
    private let spaceId: String
    private weak var output: (any SimpleSetModuleOutput)?
    
    private lazy var setDocument: any SetDocumentProtocol = {
        documentService.setDocument(objectId: objectId, spaceId: spaceId)
    }()
    
    private var details = [ObjectDetails]()
    private var objectsToLoad = 0
    var isInitial = true
    
    init(objectId: String, spaceId: String, output: (any SimpleSetModuleOutput)?) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.output = output
    }
    
    func onDisappear() {
        stopObjectsSubscription()
    }
    
    // MARK: - Subscriptions
    
    func startSubscriptions() async {
        async let detailsSub: () = subscribeOnDetails()
        async let participantSub: () = subscribeOnParticipant()
        (_,_) = await (detailsSub, participantSub)
    }
    
    private func subscribeOnDetails() async {
        for await details in setDocument.detailsPublisher.values {
            title = details.pageCellTitle
            setStateIfNeeded()
            updateRows()
        }
    }
    
    private func subscribeOnParticipant() async {
        for await participant in accountParticipantStorage.participantPublisher(spaceId: spaceId).values {
            participantCanEdit = participant.canEdit
            updateRows()
        }
    }
    
    func subscribeOnObjects() async {
        guard let state, setDocument.canStartSubscription() else { return }
        await simpleSetSubscriptionService.startSubscription(
            setDocument: setDocument,
            limit: state.limit,
            update: { [weak self] details, objectsToLoad in
                self?.details = details
                self?.objectsToLoad = objectsToLoad
                self?.updateInitialIfNeeded()
                self?.updateRows()
            })
    }
    
    private func stopObjectsSubscription() {
        Task {
            await simpleSetSubscriptionService.stopSubscription()
        }
    }
    
    // MARK: - Pagination
    
    func onAppearLastRow(_ id: String) {
        guard objectsToLoad > 0, details.last?.id == id else { return }
        objectsToLoad = 0
        state?.increaseLimit()
    }
    
    // MARK: - Actions
    
    func onObjectSelected(_ id: String) {
        guard let details = details.first(where: { $0.id == id }) else { return }
        output?.onObjectSelected(screenData: details.screenData())
    }
    
    func onDelete(objectId: String) {
        AnytypeAnalytics.instance().logMoveToBin(true)
        Task { try? await objectActionService.setArchive(objectIds: [objectId], true) }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    // MARK: - Private
    
    private func updateRows() {
        guard details.isNotEmpty else {
            data = .list([])
            return
        }
        if let setOf = setDocument.details?.filteredSetOf.first,
           let objectType = try? objectTypeProvider.objectType(id: setOf),
           objectType.isImageLayout {
            let imagesIds = details.map(\.id)
            data = .gallery(imagesIds)
        } else {
            data = .list([listSectionData(title: nil, details: details)])
        }
    }
    
    private func listSectionData(title: String?, details: [ObjectDetails]) -> ListSectionData<String?, WidgetObjectListRowModel> {
        ListSectionData(
            id: title ?? UUID().uuidString,
            data: title,
            rows: details.map { details in
                WidgetObjectListRowModel(
                    details: details,
                    canArchive: details.permissions(participantCanEdit: participantCanEdit).canArchive,
                    onTap: { [weak self] in
                        self?.output?.onObjectSelected(screenData: details.screenData())
                    }
                )
            }
        )
    }
    
    private func updateInitialIfNeeded() {
        guard isInitial else { return }
        isInitial = false
    }
    
    private func setStateIfNeeded() {
        guard state.isNil else { return }
        state = SimpleSetState()
    }
}
